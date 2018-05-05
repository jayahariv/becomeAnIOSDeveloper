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
        
        var request: URLRequest!
        do {
           
            request = try parseURLRequest(HttpConstants.ParseMethods.studentsLocation, params: params as [String: AnyObject])
        } catch {
            
            completionHandler(nil, error as NSError)
        }
        
        get(request) { (result, error) in
            
            do {
                // GUARD: no error
                guard error == nil else {
                    throw error!
                }
                
                // GUARD: result shouldn't be empty
                guard result != nil else {
                    throw NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                  code: HttpErrors.HttpErrorCode.NoResultDictionary,
                                  userInfo: nil)
                }
                
                // GUARD: result type should match and fetch the list of students
                guard let results = result![HttpConstants.ParseResponseKeys.results] as? [[String: AnyObject]] else {
                    throw NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                  code: HttpErrors.HttpErrorCode.InvalidType,
                                  userInfo: nil)
                }
                
                completionHandler(results, nil)
                
            } catch {
                
                completionHandler(nil, error as NSError)
            }
        }
    }
    
    // return Logged In user location details, if not return an empty dictionary [:]
    
    func getMyLocation(completionHandler: @escaping MyLocationHandler) {
        
        var request: URLRequest!
        do {
            // GUARD: whether account key present?
            guard let accountKey = StoreConfig.shared.accountKey else {
                throw NSError(domain: HttpErrors.HttpErrorDomain.HTTPGeneralFailure,
                              code: HttpErrors.HttpErrorCode.LoginKeyNotFound,
                              userInfo: nil)
            }
            
            let whereValue = try substitudeKeyInString(HttpConstants.ParseParameterKeys.uniqueKeyString,
                                                   key: HttpConstants.ParseParameterKeys.uniqueKey,
                                                   value: accountKey)
            let params = [
                HttpConstants.ParseParameterKeys.where: whereValue
            ]
            
            request = try parseURLRequest(HttpConstants.ParseMethods.studentsLocation, params: params as [String: AnyObject])
        
        } catch {
            
            completionHandler(nil, error as NSError)
        }
        
        get(request) { (result, error) in
            
            do {
                // GUARD make sure, no error returned!
                guard error == nil else {
                    throw error!
                }
                
                // GUARD: result shouldn't be empty
                guard result != nil else {
                    throw NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                  code: HttpErrors.HttpErrorCode.NoResultDictionary,
                                  userInfo: nil)
                }
                
                // check any locations are presnt in result
                if
                    (result as? [String: [String: AnyObject]]) != nil,
                    let results = result![HttpConstants.ParseResponseKeys.results] as? [[String: AnyObject]] {
                    
                    completionHandler( results.first, nil)
                
                } else {
                    
                    // if not send an empty dictionary
                    completionHandler([:], nil)
                }
                
            } catch {
                
                completionHandler(nil, error as NSError)
            }
        }
    }
    
    // name = name of the location
    // info = data to be posted in the location
    func postNewLocation(_ name: String, info: String, completionHandler: @escaping PostNewLocation) {
        
        OnTheMapUtils.getCoordinate(addressString: name) { [unowned self] (location, error) in
            
            // GUARD: No Error
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            self.postNewLocation(location, mediaString: info, mapString: name, completionHandler: { (createdAt, objectId, error) in
                
                guard error == nil, createdAt != nil, objectId != nil else {
                    completionHandler(nil, error!)
                    return
                }
                
                // SAVE Location ObjectID
                StoreConfig.shared.locationObjectId = objectId
                
                completionHandler(createdAt, nil)
                
            })
        }
    }
    
    // name = name of the location
    // info = data to be posted in the location
    func updateMyLocation(_ name: String, info: String, completionHandler: @escaping UpdateNewLocation) {
        OnTheMapUtils.getCoordinate(addressString: name) { [unowned self] (location, error) in
            
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
    
    typealias PrivatePostNewLocationHandler = (_ createdDate: Date?, _ objectId: String?, _ error: NSError?) -> Void
    
    func postNewLocation(_ location: CLLocationCoordinate2D,
                         mediaString: String,
                         mapString: String,
                         completionHandler: @escaping PrivatePostNewLocationHandler) {
        
        let headers = [
            HttpConstants.ParseHeaderKeys.contentType: HttpConstants.ParseConstants.applicationJSON
        ]
        
        var request: URLRequest!
        var body: [String: AnyObject]!
        do {
            
            request = try parseURLRequest(HttpConstants.ParseMethods.studentsLocation, params: [:], headers: headers)
            body = try bodyForLocation(location, mediaString: mediaString, mapString: mapString)
        } catch {
            
            completionHandler(nil, nil, error as NSError)
        }
        
        post(request, parameters: body) { (result, error) in
            
            do {
                // GUARD: No error
                guard error == nil else {
                    throw error!
                }
                
                // GUARD: valid result
                guard result != nil else {
                    throw NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                  code: HttpErrors.HttpErrorCode.NoResultDictionary,
                                  userInfo: nil)
                }
                
                // GUARD: response has valid types present
                guard
                    let createdAt = (result as? [String: String])?[HttpConstants.ParseResponseKeys.createdAt],
                    let objectId = (result as? [String: String])?[HttpConstants.ParseResponseKeys.objectId]
                else {
                    throw NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                  code: HttpErrors.HttpErrorCode.InvalidType,
                                  userInfo: nil)
                }
                
                completionHandler(Date.fromStringType1(createdAt), objectId, nil)
                
            } catch {
                completionHandler(nil, nil, error as NSError)
            }
        }
    }
    
    func updateLocation(_ location: CLLocationCoordinate2D,
                        mediaString: String,
                        mapString: String,
                        completionHandler: @escaping UpdateNewLocation) {
        
        let headers = [
            HttpConstants.ParseHeaderKeys.contentType: HttpConstants.ParseConstants.applicationJSON
        ]
        
        var request: URLRequest!
        var body: [String: AnyObject]!
        do {
            guard let objectId = StoreConfig.shared.locationObjectId else {
                throw NSError(domain: HttpErrors.HttpErrorDomain.HTTPGeneralFailure,
                              code: HttpErrors.HttpErrorCode.InvalidRequestInput,
                              userInfo: nil)
            }
            
            let requestPath = try substitudeKeyInString(HttpConstants.ParseMethods.updateStudentLocation,
                                                    key: HttpConstants.ParseParameterKeys.updateStudentLocationKey,
                                                    value: objectId)
            
            body = try bodyForLocation(location, mediaString: mediaString, mapString: mapString)
            
            request = try parseURLRequest(requestPath, params: [:], headers: headers)
            
        } catch {
            completionHandler(nil, error as NSError)
        }
 
        put(request, parameters: body) { (result, error) in
            
            do {
                // GUARD: No error
                guard error == nil else {
                    throw error!
                }
                
                // GUARD: result not empty check
                guard result != nil else {
                    throw NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                  code: HttpErrors.HttpErrorCode.NoResultDictionary,
                                  userInfo: nil)
                }
                
                guard let updatedAt = (result as? [String: String])?[HttpConstants.ParseResponseKeys.updatedAt] else {
                    throw NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                  code: HttpErrors.HttpErrorCode.InvalidType,
                                  userInfo: nil)
                }
                
                completionHandler(Date.fromStringType1(updatedAt), nil)
                
            } catch {
                
                completionHandler(nil, error as NSError)
            }
        }
    }
    
    func bodyForLocation(_ location: CLLocationCoordinate2D,
                            mediaString: String,
                            mapString: String) throws -> [String: AnyObject] {
        
        guard
            let uniqueKey = StoreConfig.shared.accountKey,
            let firstName = StoreConfig.shared.firstName,
            let lastName = StoreConfig.shared.lastName
        else {
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
    func parseURLRequest(_ path: String, params: [String: AnyObject] = [:], headers: [String: String] = [:]) throws -> URLRequest {
        
        var headersShared = [
            HttpConstants.ParseHeaderKeys.applicationId: HttpConstants.ParseConstants.AppId,
            HttpConstants.ParseHeaderKeys.restApiKey: HttpConstants.ParseConstants.RestApiId
        ]
        
        headers.forEach { (arg) in
            
            let (key, value) = arg
            headersShared[key] = value
        }
        
        return try urlRequest(.parse, path: path, headers: headersShared, params: params)
    }
}
