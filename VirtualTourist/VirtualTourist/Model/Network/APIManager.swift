//
/*
APIManager.swift
Created on: 6/23/18

Abstract:
this class will manage all the API related tasks

*/

typealias completionHandler = ((_ photosArray: [[String: AnyObject]]?, _ error: Error?) -> Void)?

import Foundation

class APIManager: NSObject {
    
    public func getImages(_ latitude: String, longitude: String, completion: completionHandler = nil) {
        onSearch(latitude, longitude: longitude, completion: completion)
    }
}

private extension APIManager {
    // MARK: Convenience
    
    func onSearch(_ latitude: String, longitude: String, completion: completionHandler) {
        let methodsParameters: [String:AnyObject] = [
            APIConstants.FlickrParameterKeys.Method: APIConstants.FlickrParameterValues.SearchMethod,
            APIConstants.FlickrParameterKeys.APIKey: APIConstants.FlickrParameterValues.APIKey,
            APIConstants.FlickrParameterKeys.BoundingBox: bboxString(latitude, longitude: latitude),
            APIConstants.FlickrParameterKeys.SafeSearch: APIConstants.FlickrParameterValues.UseSafeSearch,
            APIConstants.FlickrParameterKeys.Extras: APIConstants.FlickrParameterValues.MediumURL,
            APIConstants.FlickrParameterKeys.Format: APIConstants.FlickrParameterValues.ResponseFormat,
            APIConstants.FlickrParameterKeys.NoJSONCallback: APIConstants.FlickrParameterValues.DisableJSONCallback
            ] as [String:AnyObject]
        
        getImageFromFlickrBySearch(methodsParameters, completion: completion)
    }
    
    func bboxString(_ latitude: String, longitude: String) -> String {
        if let latitude = Double(latitude), let longitude = Double(longitude) {
            // ensure bbox is bounded by minimum and maximums
            let minimumLon = max(longitude - APIConstants.Flickr.SearchBBoxHalfWidth, APIConstants.Flickr.SearchLonRange.0)
            let minimumLat = max(latitude - APIConstants.Flickr.SearchBBoxHalfHeight, APIConstants.Flickr.SearchLatRange.0)
            let maximumLon = min(longitude + APIConstants.Flickr.SearchBBoxHalfWidth, APIConstants.Flickr.SearchLonRange.1)
            let maximumLat = min(latitude + APIConstants.Flickr.SearchBBoxHalfHeight, APIConstants.Flickr.SearchLatRange.1)
            return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
        } else {
            return "0,0,0,0"
        }
        
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
