//
//  HttpClient+Parse.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/3/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import Foundation
import CoreLocation

// MARK: ----- Completion Handler Type Alias -----

typealias StudentLocationHandler = (_ studentLocation: [[String: AnyObject]]?, _ error: NSError?) -> Void
typealias MyLocationHandler = (_ location: [String: AnyObject]?, _ error: NSError?) -> Void
typealias PostNewLocation = (_ createdDate: Date?, _ error: NSError?) -> Void
typealias UpdateNewLocation = (_ updatedDate: Date?, _ error: NSError?) -> Void

// MARK: ----- Parse Specific Enums -----
// struct defined for the sorting order keys
struct StudentLocationSortOrder {
    static let updatedAt = "updatedAt"
    static let inverseUpdatedAt = "-updatedAt"
}

extension HttpClient {
    
    // MARK: ----- Public APIs -----
    /*
        Page, PageCount => this function will receive the page number and number of items per page.
        For example, page=1, pageCount=100 will return the first 100 items. For page=2, pageCount=200, you will reieve
        200 to 400 items. It will calculate page with respect to the pageCount.
     
        sort => StudentLocationSortOrder struct value can be used to define it.
     
     */
    func getStudentLocation(_ page: Int,
                            pageCount: Int,
                            sort: String,
                            completionHandler: @escaping StudentLocationHandler) {
        
        let params = [
            HttpConstants.ParseParameterKeys.limit: String(pageCount),
            HttpConstants.ParseParameterKeys.skip: String((page - 1) * pageCount),
            HttpConstants.ParseParameterKeys.order: sort
        ]
        
        guard let request = parseURLRequest(HttpConstants.ParseMethods.studentsLocation, params: params as [String: AnyObject]) else {
            
            let error = NSError(domain: HttpErrors.HttpErrorDomain.HTTPGeneralFailure,
                                code: HttpErrors.HttpErrorCode.RequestCreationError,
                                userInfo: nil)
            completionHandler(nil, error)
            return
        }
        
        get(request) { (result, error) in
            
            // GUARD: no error
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            // GUARD: result shouldn't be empty
            guard result != nil else {
                completionHandler(nil, NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                               code: HttpErrors.HttpErrorCode.NoResultDictionary,
                                               userInfo: nil))
                return
            }
            
            // GUARD: result type should match and fetch the list of students
            guard let results = result![HttpConstants.ParseResponseKeys.results] as? [[String: AnyObject]] else {
                completionHandler(nil, NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                               code: HttpErrors.HttpErrorCode.InvalidType,
                                               userInfo: nil))
                return
            }
            
            completionHandler(results, nil)
        }
    }
    
    // return Logged In user location details, if not return an empty dictionary [:]
    
    func getMyLocation(completionHandler: @escaping MyLocationHandler) {
        
        // GUARD: whether account key present?
        guard let accountKey = StoreConfig.shared.accountKey else {
            completionHandler(nil, NSError(domain: HttpErrors.HttpErrorDomain.HTTPGeneralFailure,
                                           code: HttpErrors.HttpErrorCode.LoginKeyNotFound,
                                           userInfo: nil))
            return
        }
        let params = [
            HttpConstants.ParseParameterKeys.where: substitudeKeyInString(HttpConstants.ParseParameterKeys.uniqueKeyString,
                                                                          key: HttpConstants.ParseParameterKeys.uniqueKey,
                                                                          value: accountKey)
        ]
        
        // GUARD: Valid request created
        guard let request = parseURLRequest(HttpConstants.ParseMethods.studentsLocation, params: params as [String: AnyObject]) else {
            completionHandler(nil, NSError(domain: HttpErrors.HttpErrorDomain.HTTPGeneralFailure,
                                           code: HttpErrors.HttpErrorCode.RequestCreationError,
                                           userInfo: nil))
            return
        }
        
        get(request) { (result, error) in
            
            // GUARD make sure, no error returned!
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            // GUARD: result shouldn't be empty
            guard result != nil else {
                completionHandler(nil, NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                               code: HttpErrors.HttpErrorCode.NoResultDictionary,
                                               userInfo: nil))
                return
            }
            
            // GUARD: result type should be matching
            if
                (result as? [String: [String: AnyObject]]) != nil,
                let results = result![HttpConstants.ParseResponseKeys.results] as? [[String: AnyObject]] {
                
                completionHandler( results.first, nil)
                
            }
            
            completionHandler([:], nil)
            
        }
    }
    
    // name = name of the location
    // info = data to be posted in the location
    func postNewLocation(_ name: String, info: String, completionHandler: @escaping PostNewLocation) {
        OnTheMapUtils.getCoordinate(addressString: name) { [unowned self] (location, error) in
            
            func showError(_ code: Int) {
                let error = NSError(domain: HttpErrors.HttpErrorDomain.HTTPGeneralFailure,
                                    code: code,
                                    userInfo: nil)
                completionHandler(nil, error)
            }
            
            // GUARD: No Error
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            self.postNewLocation(location, mediaString: info, mapString: name, completionHandler: completionHandler)
        }
    }
    
    // name = name of the location
    // info = data to be posted in the location
    func updateMyLocation(_ name: String, info: String, completionHandler: @escaping UpdateNewLocation) {
        OnTheMapUtils.getCoordinate(addressString: name) { [unowned self] (location, error) in
            
            func showError(_ code: Int) {
                let error = NSError(domain: HttpErrors.HttpErrorDomain.HTTPGeneralFailure,
                                    code: code,
                                    userInfo: nil)
                completionHandler(nil, error)
            }
            
            // GUARD: No Error
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            self.updateLocation(location, mediaString: info, mapString: name, completionHandler: completionHandler)
        }
    }
}

// MARK: ----- Private APIs -----

private extension HttpClient {
    
    func postNewLocation(_ location: CLLocationCoordinate2D,
                         mediaString: String,
                         mapString: String,
                         completionHandler: @escaping PostNewLocation) {
        
        let headers = [
            HttpConstants.ParseHeaderKeys.contentType: HttpConstants.ParseConstants.applicationJSON
        ]
        
        
        guard let request = parseURLRequest(HttpConstants.ParseMethods.studentsLocation, params: [:], headers: headers) else {
            let error = NSError(domain: HttpErrors.HttpErrorDomain.HTTPGeneralFailure,
                          code: HttpErrors.HttpErrorCode.RequestCreationError,
                          userInfo: nil)
            completionHandler(nil, error)
            return
        }
        
        var body: [String: AnyObject]? = nil
        
        do {
            body = try bodyForLocation(location, mediaString: mediaString, mapString: mapString)
        } catch {
            
            completionHandler(nil, error as NSError)
        }
        
        
        post(request, parameters: body) { (result, error) in
            
            func showError(_ code: Int) {
                let error = NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                    code: code,
                                    userInfo: nil)
                completionHandler(nil, error)
            }
            
            // GUARD: No error
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            // GUARD: valid result
            guard result != nil else {
                showError(HttpErrors.HttpErrorCode.NoResultDictionary)
                return
            }
            
            guard
                let createdAt = (result as? [String: String])?[HttpConstants.ParseResponseKeys.createdAt],
                let objectId = (result as? [String: String])?[HttpConstants.ParseResponseKeys.objectId]
            else {
                showError(HttpErrors.HttpErrorCode.InvalidType)
                return
            }
            
            StoreConfig.shared.locationObjectId = objectId
            
            completionHandler(Date.fromStringType1(createdAt), nil)
        }
    }
    
    func updateLocation(_ location: CLLocationCoordinate2D,
                        mediaString: String,
                        mapString: String,
                        completionHandler: @escaping UpdateNewLocation) {
        
        guard let objectId = StoreConfig.shared.locationObjectId else {
            completionHandler(nil, NSError(domain: HttpErrors.HttpErrorDomain.HTTPGeneralFailure,
                                           code: HttpErrors.HttpErrorCode.InvalidRequestInput,
                                           userInfo: nil))
            return
        }
        guard let requestPath = substitudeKeyInString(HttpConstants.ParseMethods.updateStudentLocation,
                                                      key: HttpConstants.ParseParameterKeys.updateStudentLocationKey,
                                                      value: objectId)
            else {
                completionHandler(nil, NSError(domain: HttpErrors.HttpErrorDomain.HTTPGeneralFailure,
                                               code: HttpErrors.HttpErrorCode.InvalidRequestInput,
                                               userInfo: nil))
                return
        }
        
        let headers = [
            HttpConstants.ParseHeaderKeys.contentType: HttpConstants.ParseConstants.applicationJSON
        ]
        
        var body: [String: AnyObject]? = nil
        
        do {
            body = try bodyForLocation(location, mediaString: mediaString, mapString: mapString)
        } catch {
            completionHandler(nil, error as NSError)
        }
        
        guard let request = parseURLRequest(requestPath, params: [:], headers: headers) else {
            completionHandler(nil, NSError(domain: HttpErrors.HttpErrorDomain.HTTPGeneralFailure,
                                           code: HttpErrors.HttpErrorCode.InvalidRequestInput,
                                           userInfo: nil))
            return
        }
        
        put(request, parameters: body) { (result, error) in
            
            // GUARD: No error
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            func showError(_ code: Int) {
                let error = NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                    code: code,
                                    userInfo: nil)
                completionHandler(nil, error)
            }
            
            // GUARD: result not empty check
            guard result != nil else {
                showError(HttpErrors.HttpErrorCode.NoResultDictionary)
                return
            }
            
            guard let updatedAt = (result as? [String: String])?["updatedAt"] else {
                showError(HttpErrors.HttpErrorCode.InvalidType)
                return
            }
            
            completionHandler(Date.fromStringType1(updatedAt), nil)
        }
    }
    
    func bodyForLocation(_ location: CLLocationCoordinate2D,
                            mediaString: String,
                            mapString: String) throws -> [String: AnyObject]? {
        
        guard let uniqueKey = StoreConfig.shared.accountKey else {
            throw NSError(domain: HttpErrors.HttpErrorDomain.HTTPGeneralFailure,
                          code: HttpErrors.HttpErrorCode.InvalidRequestInput,
                          userInfo: nil)
        }
        
        guard let firstName = StoreConfig.shared.firstName else {
            throw NSError(domain: HttpErrors.HttpErrorDomain.HTTPGeneralFailure,
                          code: HttpErrors.HttpErrorCode.InvalidRequestInput,
                          userInfo: nil)
        }
        
        guard let lastName = StoreConfig.shared.lastName else {
            throw NSError(domain: HttpErrors.HttpErrorDomain.HTTPGeneralFailure,
                          code: HttpErrors.HttpErrorCode.InvalidRequestInput,
                          userInfo: nil)
        }
        
        return [
            HttpConstants.ParseParameterKeys.uniqueKey: uniqueKey,
            HttpConstants.ParseParameterKeys.firstName: firstName,
            HttpConstants.ParseParameterKeys.lastName: lastName,
            HttpConstants.ParseParameterKeys.mapString: mapString,
            HttpConstants.ParseParameterKeys.mediaURL: mediaString,
            HttpConstants.ParseParameterKeys.latitude: location.latitude,
            HttpConstants.ParseParameterKeys.longitude: location.longitude,
            ] as [String: AnyObject]
    }
    
    // this method will convert input as Parse API compatible URLRequest
    func parseURLRequest(_ path: String, params: [String: AnyObject] = [:], headers: [String: String] = [:]) -> URLRequest? {
        
        var headersShared = [
            HttpConstants.ParseHeaderKeys.applicationId: HttpConstants.ParseConstants.AppId,
            HttpConstants.ParseHeaderKeys.restApiKey: HttpConstants.ParseConstants.RestApiId
        ]
        
        headers.forEach { (arg) in
            
            let (key, value) = arg
            headersShared[key] = value
        }
        return urlRequest(.parse,
                          path: path,
                          headers: headersShared,
                          params: params)
    }
}
