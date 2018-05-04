//
//  HttpClient+Parse.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/3/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import Foundation

typealias StudentLocationHandler = (_ studentLocation: [[String: AnyObject]]?, _ error: NSError?) -> Void
typealias MyLocationHandler = (_ location: [String: AnyObject]?, _ error: NSError?) -> Void

// struct defined for the sorting order keys
struct StudentLocationSortOrder {
    static let updatedAt = "updatedAt"
    static let inverseUpdatedAt = "-updatedAt"
}

extension HttpClient {
    
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
            "where": "{\"uniqueKey\":\"\(accountKey)\"}"
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
    
    // this method will convert input as Parse API compatible URLRequest
    func parseURLRequest(_ path: String, params: [String: AnyObject] = [:]) -> URLRequest? {
        
        let headers = [
            HttpConstants.ParseHeaderKeys.applicationId: HttpConstants.ParseConstants.AppId,
            HttpConstants.ParseHeaderKeys.restApiKey: HttpConstants.ParseConstants.RestApiId
        ]
        return urlRequest(.parse,
                   path: HttpConstants.ParseMethods.studentsLocation,
                   headers: headers,
                   params: params)
    }
}
