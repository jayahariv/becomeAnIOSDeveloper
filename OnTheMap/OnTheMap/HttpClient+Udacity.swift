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
typealias UdacityLogoutCompletionHandler = (_ successs: Bool, _ error: NSError?) -> Void

extension HttpClient {
    
    // MARK: ------ Public APIs ------
    
    // log in
    func authenticate(userName: String,
                      password: String,
                      completionHandler: @escaping UdacityNewSessionCompletionHandler) {
        
        getNewSession(userName: userName, password: password) { [unowned self] (sessionId, sessionExpiry, accountKey, error) in
            
            do {
                guard error == nil else {
                    throw error!
                }
                
                guard sessionId != nil, sessionExpiry != nil, accountKey != nil else {
                    throw NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                  code: HttpErrors.HttpErrorCode.LoginKeyNotFound,
                                  userInfo: nil)
                }
                
                // SAVE DATA to STORE
                StoreConfig.shared.sessionId = sessionId
                StoreConfig.shared.sessionExpiry = sessionExpiry
                StoreConfig.shared.accountKey = accountKey
                
                self.getPublicUserData(completionHandler: { (firstName, lastName, error) in
                    
                    do {
                        guard error == nil else {
                            throw error!
                        }
                        
                        guard firstName != nil, lastName != nil else {
                            throw NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                          code: HttpErrors.HttpErrorCode.NoValidResultDictionary,
                                          userInfo: nil)
                        }
                        
                        // SAVE DATA to STORE
                        StoreConfig.shared.firstName = firstName
                        StoreConfig.shared.lastName = lastName
                        
                        completionHandler(true, nil)
                        
                    } catch {
                        completionHandler(false, error as NSError)
                    }
                })
                
            } catch {
                completionHandler(false, error as NSError)
            }
        }
    }
    
    func logout(completionHandler: @escaping UdacityLogoutCompletionHandler) {
        // request
        var request: URLRequest!
        do {
            
            request = try udacityRequest(HttpConstants.UdacityMethods.AuthenticationSession)
            var xsrfCookie: HTTPCookie? = nil
            let sharedCookieStorage = HTTPCookieStorage.shared
            for cookie in sharedCookieStorage.cookies! {
                if cookie.name == HttpConstants.UdacityParameterKeys.XCRF_Token { xsrfCookie = cookie }
            }
            if let xsrfCookie = xsrfCookie {
                request.setValue(xsrfCookie.value, forHTTPHeaderField: HttpConstants.UdacityParameterKeys.XCRF_Token)
            }
        } catch {
            
            completionHandler(false, error as NSError)
        }
        
        task(HttpConstants.HTTPMethod.DELETE, urlRequest: request) { (result, error) in
            do {
                guard error == nil else {
                    throw error!
                }
                
                guard result != nil else {
                    throw NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                  code: HttpErrors.HttpErrorCode.NoValidResultDictionary,
                                  userInfo: nil)
                }
                
                guard
                    let session = (result as? [String: [String: String]])?[HttpConstants.UdacityResponseKeys.session],
                    let expiration = session[HttpConstants.UdacityResponseKeys.sessionExpiry]
                else {
                    throw NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                  code: HttpErrors.HttpErrorCode.InvalidType,
                                  userInfo: nil)
                }
                
                StoreConfig.shared.sessionExpiry = expiration
                
                completionHandler(true, nil)
                
            } catch {
                completionHandler(false, error as NSError)
            }
        }
    }
}


private extension HttpClient {
    
    typealias HttpClientNewSessionHandler = (_ sessionId: String?, _ sessionExpiry: String?,  _ accountKet: String?, _ error: NSError?) -> Void
    typealias HttpClientPublicUserDataHandler = (_ firstName: String?, _ lastName: String?, _ error: NSError?) -> Void
    
    // MARK: ------ Private APIs ------
    
    func getNewSession(userName: String,
                       password: String,
                       completionHandler: @escaping HttpClientNewSessionHandler) {
        // request
        var request: URLRequest!
        do {
            
            request = try udacityRequest(HttpConstants.UdacityMethods.AuthenticationSession)
        } catch {
            
            completionHandler(nil, nil, nil, error as NSError)
        }
        
        // body
        let body = [
            HttpConstants.UdacityParameterKeys.udacity: [
                HttpConstants.UdacityParameterKeys.username: userName,
                HttpConstants.UdacityParameterKeys.password: password,
            ] as AnyObject
        ] as AnyObject
        
        task(HttpConstants.HTTPMethod.POST, urlRequest: request, body: body) {(result, error) in
            
            do {
                // GUARD: No error present
                guard error == nil else {
                    throw error!
                }
                
                // GUARD: parse and check whether the correct response is returned
                guard
                    ((result as? Dictionary<String, AnyObject>) != nil),
                    let sessionDetails = result![HttpConstants.UdacityResponseKeys.session] as? Dictionary<String, String>,
                    let sessionId = sessionDetails[HttpConstants.UdacityResponseKeys.sessionId],
                    let sessionExpiry = sessionDetails[HttpConstants.UdacityResponseKeys.sessionExpiry],
                    let accountDetails = result![HttpConstants.UdacityResponseKeys.account] as? Dictionary<String, AnyObject>,
                    let accountKey = accountDetails[HttpConstants.UdacityResponseKeys.accountKey] as? String
                    else {
                        throw NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                      code: HttpErrors.HttpErrorCode.InvalidType,
                                      userInfo: nil)
                }
                
                // SUCCESS
                completionHandler(sessionId, sessionExpiry, accountKey, nil)
                
            } catch {
                completionHandler(nil, nil, nil, error as NSError)
            }
        }
    }
    
    // get user data
    func getPublicUserData(completionHandler: @escaping HttpClientPublicUserDataHandler) {
        
        // GUARD: whether substituted string returns a valid string
        var request: URLRequest!
        do {
            
            // GUARD: check whether Login Key Present or not
            guard let userId = StoreConfig.shared.accountKey else {
                throw NSError(domain: HttpErrors.HttpErrorDomain.HTTPGeneralFailure,
                              code: HttpErrors.HttpErrorCode.LoginKeyNotFound,
                              userInfo: nil)
            }
            
            let method = try substitudeKeyInString(HttpConstants.UdacityMethods.PublicUserData,
                                               key: HttpConstants.UdacityParameterKeys.publicUserDataIDKey,
                                               value: userId)
            request = try udacityRequest(method)
        } catch {
            
            completionHandler(nil, nil, error as NSError)
        }
        
        get(request) { (result, error) in
            
            do {
                // GUARD: error not empty
                guard error == nil else {
                    throw error!
                }
                
                // GUARD: Result not empty
                guard result != nil else {
                    throw NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                  code: HttpErrors.HttpErrorCode.NoResultDictionary,
                                  userInfo: nil)
                }
                
                // GUARD: check for valid user present in response
                guard
                    let user = (result as? [String: AnyObject])?[HttpConstants.UdacityResponseKeys.user] as? [String: AnyObject],
                    let lastName = user[HttpConstants.UdacityResponseKeys.lastName] as? String,
                    let firstName = user[HttpConstants.UdacityResponseKeys.firstName] as? String
                    else {
                        throw NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                      code: HttpErrors.HttpErrorCode.InvalidType,
                                      userInfo: nil)
                }
                
                // SUCCESS
                completionHandler(firstName, lastName, nil)
                
            } catch {
                
                completionHandler(nil, nil, error as NSError)
            }
        }
    }
    
    func udacityRequest(_ path: String, params: [String: AnyObject] = [:]) throws -> URLRequest {
        return try urlRequest(.udacity, path: path, headers: [:], params: params)
    }
}
