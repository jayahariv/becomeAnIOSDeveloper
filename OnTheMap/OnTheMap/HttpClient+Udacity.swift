//
//  HttpClient+Udacity.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/1/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import Foundation

typealias UdacityNewSessionCompletionHandler = (_ sessionId: String?, _ expiry: String?, _ error: NSError?) -> Void

extension HttpClient {
    
    // MARK: ------ Public APIs ------
    func authenticate(userName: String,
                      password: String,
                      completionHandler: @escaping UdacityNewSessionCompletionHandler) {
        
        getNewSession(userName: userName, password: password, completionHandler: completionHandler)
        
    }
    
    // MARK: ------ Private APIs ------
    
    private func getNewSession(userName: String,
                               password: String,
                               completionHandler: @escaping UdacityNewSessionCompletionHandler) {
        
        // GUARD: whether the request created successfully
        guard let request = udacityRequest(HttpConstants.UdacityMethods.AuthenticationSession) else {
            
            let error = NSError(domain: HttpErrors.HttpErrorDomain.HTTPGeneralFailure,
                                code: HttpErrors.HttpErrorCode.RequestCreationError, userInfo: nil)
            completionHandler(nil, nil, error)
            return
        }
        
        let bodyParams = ["udacity": [ "username": userName, "password": password ]] as [String : AnyObject]
        post(request, parameters: bodyParams) { [unowned self] (result, error) in
            
            func showError(_ code: Int) {
                let error = NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                    code: code, userInfo: error?.userInfo)
                completionHandler(nil, nil, error)
            }
            
            // GUARD: No error present
            guard error == nil else {
                completionHandler(nil, nil, error)
                return
            }
            
            // GUARD: whether some valid result returned
            guard ((result as? Dictionary<String, AnyObject>) != nil) else {
                showError(HttpErrors.HttpErrorCode.InvalidType)
                return
            }
            
            // GUARD: a valid session details present in response
            guard let sessionDetails = result![HttpConstants.UdacityResponseKeys.session] as? Dictionary<String, String> else {
                showError(HttpErrors.HttpErrorCode.InvalidType)
                return
            }
            
            // GUARD: valid session-ID and sessionExpiry present inside the session details
            guard
                let sessionId = sessionDetails[HttpConstants.UdacityResponseKeys.sessionId],
                let sessionExpiry = sessionDetails[HttpConstants.UdacityResponseKeys.sessionExpiry]
            else {
                showError(HttpErrors.HttpErrorCode.InvalidType)
                return
            }
            
            guard let accountDetails = result![HttpConstants.UdacityResponseKeys.account] as? Dictionary<String, AnyObject> else {
                showError(HttpErrors.HttpErrorCode.InvalidType)
                return
            }
            
            // GUARD: valid session-ID and sessionExpiry present inside the session details
            guard let accountKey = accountDetails[HttpConstants.UdacityResponseKeys.accountKey] as? String else {
                showError(HttpErrors.HttpErrorCode.InvalidType)
                return
            }
            
            StoreConfig.shared.sessionId = sessionId
            StoreConfig.shared.sessionExpiry = sessionExpiry
            StoreConfig.shared.accountKey = accountKey
            
            // SUCCESS
            completionHandler(sessionId, sessionExpiry, nil)
        }
    }
    
    func udacityRequest(_ path: String, params: [String: AnyObject] = [:]) -> URLRequest? {
        return urlRequest(.udacity, path: path, headers: [:], params: params)
    }
}
