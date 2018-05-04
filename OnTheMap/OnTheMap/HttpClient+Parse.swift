//
//  HttpClient+Parse.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/3/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import Foundation

typealias StudentLocationHandler = (_ studentLocation: [[String: AnyObject]]?, _ error: NSError?) -> Void

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
        let headers = [
            HttpConstants.ParseHeaderKeys.applicationId: HttpConstants.ParseConstants.AppId,
            HttpConstants.ParseHeaderKeys.restApiKey: HttpConstants.ParseConstants.RestApiId
        ]
        
        guard
            let request = urlRequest(.parse,
                                     path: HttpConstants.ParseMethods.studentsLocation,
                                     headers: headers,
                                     params: params)
        else {
            let error = NSError(domain: HttpErrors.HttpErrorDomain.HTTPGeneralFailure,
                                code: HttpErrors.HttpErrorCode.RequestCreationError, userInfo: nil)
            completionHandler(nil, error)
            return
        }
        get(request) { (result, error) in
            
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            guard result != nil else {
                completionHandler(nil, NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                               code: HttpErrors.HttpErrorCode.NoResultDictionary,
                                               userInfo: nil))
                return
            }
            
            guard let results = result![HttpConstants.ParseResponseKeys.results] as? [[String: AnyObject]] else {
                completionHandler(nil, NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                               code: HttpErrors.HttpErrorCode.InvalidType,
                                               userInfo: nil))
                return
            }
            
            completionHandler(results, nil)
        }
    }
}
