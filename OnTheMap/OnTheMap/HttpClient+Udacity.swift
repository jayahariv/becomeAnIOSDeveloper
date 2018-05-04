//
//  HttpClient+Udacity.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/1/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import Foundation

// MARK: Completion Handlers
typealias UdacityNewSessionCompletionHandler = (_ success: Bool, _ error: NSError?) -> Void
typealias UdacityUserDataCompletionHandler = (_ firstName: String?, _ lastName: String?, _ error: NSError?) -> Void

extension HttpClient {
    
    // MARK: ------ Public APIs ------
    
    // log in
    func authenticate(userName: String,
                      password: String,
                      completionHandler: @escaping UdacityNewSessionCompletionHandler) {
        
        getNewSession(userName: userName, password: password) { [unowned self] (sessionId, accountKey, error) in
            
            func showError(_ code: Int) {
                let error = NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                    code: code,
                                    userInfo: nil)
                completionHandler(false, error)
            }
            
            guard error == nil else {
                completionHandler(false, error)
                return
            }
            
            guard sessionId != nil else {
                showError(HttpErrors.HttpErrorCode.LoginKeyNotFound)
                return
            }
            
            guard accountKey != nil else {
                showError(HttpErrors.HttpErrorCode.LoginKeyNotFound)
                return
            }
            
            self.getPublicUserData(completionHandler: { (firstName, lastName, error) in
                func showError(_ code: Int) {
                    let error = NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                        code: code,
                                        userInfo: nil)
                    completionHandler(false, error)
                }
                
                guard error == nil else {
                    completionHandler(false, error)
                    return
                }
                
                guard firstName != nil else {
                    showError(HttpErrors.HttpErrorCode.NoValidResultDictionary)
                    return
                }
                
                guard lastName != nil else {
                    showError(HttpErrors.HttpErrorCode.NoValidResultDictionary)
                    return
                }
                
                completionHandler(true, nil)
                
            })
        }
        
    }
}

private extension HttpClient {
    // MARK: ------ Private APIs ------
    
    func getNewSession(userName: String,
                       password: String,
                       completionHandler: @escaping (_ sessionId: String?, _ accountKet: String?, _ error: NSError?) -> Void) {
        
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
            
            // SAVE DATA to STORE
            StoreConfig.shared.sessionId = sessionId
            StoreConfig.shared.sessionExpiry = sessionExpiry
            StoreConfig.shared.accountKey = accountKey
            
            // SUCCESS
            completionHandler(sessionId, accountKey, nil)
        }
    }
    
    // get user data
    func getPublicUserData(completionHandler: @escaping UdacityUserDataCompletionHandler) {
        
        func showError(_ code: Int) {
            let error = NSError(domain: HttpErrors.HttpErrorDomain.HTTPGeneralFailure,
                                code: code,
                                userInfo: nil)
            completionHandler(nil, nil, error)
        }
        
        // GUARD: check whether Login Key Present or not
        guard let userId = StoreConfig.shared.accountKey else {
            
            showError(HttpErrors.HttpErrorCode.LoginKeyNotFound)
            return
        }
        
        // GUARD: whether substituted string returns a valid string
        guard
            let method = substitudeKeyInString(HttpConstants.UdacityMethods.PublicUserData,
                                               key: HttpConstants.UdacityParameterKeys.publicUserDataIDKey,
                                               value: userId)
            else {
                
                showError(HttpErrors.HttpErrorCode.RequestCreationError)
                return
        }
        
        // GUARD: check a valid request is created
        guard let request = udacityRequest(method) else {
            
            showError(HttpErrors.HttpErrorCode.RequestCreationError)
            return
        }
        
        
        get(request) { (result, error) in
            
            // GUARD: error not empty
            guard error == nil else {
                completionHandler(nil, nil, error)
                return
            }
            
            func showError(_ code: Int) {
                let error = NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                    code: code,
                                    userInfo: nil)
                completionHandler(nil, nil, error)
            }
            
            // GUARD: Result not empty
            guard result != nil else {
                
                showError(HttpErrors.HttpErrorCode.NoResultDictionary)
                return
            }
            
            // GUARD: check for valid user present in response
            guard let user = (result as? [String: AnyObject])?[HttpConstants.UdacityResponseKeys.user] as? [String: AnyObject] else {
                
                showError(HttpErrors.HttpErrorCode.InvalidType)
                return
            }
            
            // GUARD: check user data contains lastName and firstName data
            guard
                let lastName = user[HttpConstants.UdacityResponseKeys.lastName] as? String,
                let firstName = user[HttpConstants.UdacityResponseKeys.firstName] as? String
                else {
                    
                    showError(HttpErrors.HttpErrorCode.InvalidType)
                    return
            }
            
            // SAVE DATA to STORE
            StoreConfig.shared.firstName = firstName
            StoreConfig.shared.lastName = lastName
            
            // SUCCESS
            completionHandler(firstName, lastName, nil)
        }
    }
    
    func udacityRequest(_ path: String, params: [String: AnyObject] = [:]) -> URLRequest? {
        return urlRequest(.udacity, path: path, headers: [:], params: params)
    }
}
