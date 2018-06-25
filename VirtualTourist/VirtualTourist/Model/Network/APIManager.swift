//
/*
APIManager.swift
Created on: 6/23/18

Abstract:
this class will manage all the API related tasks

*/

import UIKit

typealias completionHandler = ((_ photosArray: [[String: AnyObject]]?, _ error: Error?) -> Void)?
typealias fetchPhotoCompletionHandler = ((_ photo: UIImage?, _ error: Error?) -> Void)?

class APIManager: NSObject {
    
    public static let shared = APIManager()
    
    /**
     fetched the images for the given latitude and longitude, and completion handler will have the photos or error details.
     - parameters:
         - latitude: self descriptive
         - longitude: self descriptive
         - completion: (optional) completion handler with fetched images or error with details.
     */
    public func getImages(_ latitude: Double, longitude: Double, completion: completionHandler = nil) {
        onSearch(latitude, longitude: longitude, completion: completion)
    }
    
    /**
     this will return a vaild photo if it already fetched and saved in core data.
     - parameters:
        - photoURL: medium URL of the image.
     */
    public func fetchedPhoto(_ photoURL: URL) -> UIImage? {
        return nil
    }
    
    /**
     fetch, save the binary data and return the image to the caller
     - parameters:
        - photoURL: self descriptive.
     */
    public func fetchAndSaveImage(_ photoURL: URL, completion: fetchPhotoCompletionHandler = nil){
        // TODO: fetch and save the image
    }
}

private extension APIManager {
    // MARK: Convenience
    
    func onSearch(_ latitude: Double, longitude: Double, completion: completionHandler) {
        let methodsParameters: [String:AnyObject] = [
            APIConstants.FlickrParameterKeys.Method: APIConstants.FlickrParameterValues.SearchMethod,
            APIConstants.FlickrParameterKeys.APIKey: APIConstants.FlickrParameterValues.APIKey,
            APIConstants.FlickrParameterKeys.BoundingBox: bboxString(latitude: latitude, longitude: latitude),
            APIConstants.FlickrParameterKeys.SafeSearch: APIConstants.FlickrParameterValues.UseSafeSearch,
            APIConstants.FlickrParameterKeys.Extras: APIConstants.FlickrParameterValues.MediumURL,
            APIConstants.FlickrParameterKeys.Format: APIConstants.FlickrParameterValues.ResponseFormat,
            APIConstants.FlickrParameterKeys.NoJSONCallback: APIConstants.FlickrParameterValues.DisableJSONCallback,
            APIConstants.FlickrParameterKeys.PerPage: APIConstants.FlickrParameterValues.PerPageCount
            ] as [String:AnyObject]
        
        getImageFromFlickrBySearch(methodsParameters, completion: completion)
    }
    
    func bboxString(latitude: Double, longitude: Double) -> String {
        let minimumLon = max(longitude - APIConstants.Flickr.SearchBBoxHalfWidth, APIConstants.Flickr.SearchLonRange.0)
        let minimumLat = max(latitude - APIConstants.Flickr.SearchBBoxHalfHeight, APIConstants.Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + APIConstants.Flickr.SearchBBoxHalfWidth, APIConstants.Flickr.SearchLonRange.1)
        let maximumLat = min(latitude + APIConstants.Flickr.SearchBBoxHalfHeight, APIConstants.Flickr.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    // Creating a URL from Parameters
    
    func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = APIConstants.Flickr.APIScheme
        components.host = APIConstants.Flickr.APIHost
        components.path = APIConstants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    func getImageFromFlickrBySearch(_ methodParameters: [String: AnyObject], completion: completionHandler) {
        // create session and request
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                let error = NSError(domain: "Image Failure", code: 1001, userInfo: ["message" : error]) as Error
                completion?(nil, error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[APIConstants.FlickrResponseKeys.Status] as? String, stat == APIConstants.FlickrResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is "photos" key in our result? */
            guard let photosDictionary = parsedResult[APIConstants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                displayError("Cannot find keys '\(APIConstants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is "pages" key in the photosDictionary? */
            guard let totalPages = photosDictionary[APIConstants.FlickrResponseKeys.Pages] as? Int else {
                displayError("Cannot find key '\(APIConstants.FlickrResponseKeys.Pages)' in \(photosDictionary)")
                return
            }
            
            // pick a random page!
            let pageLimit = min(totalPages, 40)
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            self.getImageFromFlickrBySearch(methodParameters, withPageNumber: randomPage, completion: completion)
        }
        
        // start the task!
        task.resume()
    }
    
    func getImageFromFlickrBySearch(_ methodParameters: [String: AnyObject], withPageNumber: Int, completion: completionHandler) {
        
        // add the page to the method's parameters
        var methodParametersWithPageNumber = methodParameters
        methodParametersWithPageNumber[APIConstants.FlickrParameterKeys.Page] = withPageNumber as AnyObject?
        
        // create session and request
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                let error = NSError(domain: "Image Failure", code: 1001, userInfo: ["message" : error]) as Error
                completion?(nil, error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[APIConstants.FlickrResponseKeys.Status] as? String, stat == APIConstants.FlickrResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photos" key in our result? */
            guard let photosDictionary = parsedResult[APIConstants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                displayError("Cannot find key '\(APIConstants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photo" key in photosDictionary? */
            guard let photosArray = photosDictionary[APIConstants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                displayError("Cannot find key '\(APIConstants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
                return
            }
            
            if photosArray.count == 0 {
                displayError("No Photos Found. Search Again.")
                return
            } else {
                completion?(photosArray, nil)
            }
        }
        
        // start the task!
        task.resume()
    }
}
