//
//  HttpClient.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/1/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import Foundation

class HttpClient {
    
    // URL Session Property
    
    private lazy var session: URLSession = {
        return URLSession(configuration: URLSessionConfiguration.ephemeral)
    }()
    
    // MARK: ------ PRIVATE APIs ------
    
    // Session Task
    private func task(_ urlRequest: URLRequest,
              completionHandler: @escaping (_ result: AnyObject?, _ error: Error?) -> Void) {
        
        let task = session.dataTask(with: urlRequest) { [unowned self] (data, response, error) in
            
            func finishWithError(_ code: Int) {
                
                let error = NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure, code: code, userInfo: nil)
                
                completionHandler(nil, error)
            }
            
            guard error == nil else {
                
                finishWithError(HttpErrors.HttpErrorCode.ErrorNotEmpty)
                return
            }
            
            guard data != nil else {
                
                finishWithError(HttpErrors.HttpErrorCode.NoData)
                return
            }
            
            guard
                let statusCode = (response as? HTTPURLResponse)?.statusCode,
                statusCode <= 299, statusCode >= 200
            else {
                
                finishWithError(HttpErrors.HttpErrorCode.InvalidStatusCode)
                return
            }
            
            guard
                let serializedData = try? JSONSerialization.jsonObject(with: data!,
                                                                       options: .allowFragments) as AnyObject
            else {
                
                finishWithError(HttpErrors.HttpErrorCode.InvalidJSONObject)
                return
            }
            
            completionHandler(serializedData, nil)
        }
        
        task.resume()
    }
    
    
    // GET request
    private func get(_ urlRequest: URLRequest, completionHandler: @escaping (_ result: AnyObject?, _ error: Error?) -> Void) {
        print(urlRequest.url?.absoluteString ?? "NO URL!!!")
        task(urlRequest, completionHandler: completionHandler)
    }
    
    // POST request
    private func post(_ urlRequest: URLRequest,
              parameters: [String: String]?,
              completionHandler: @escaping (_ result: AnyObject?, _ error: Error?) -> Void) {
  
        var mutableURLRequest = urlRequest
        mutableURLRequest.addValue("application/json", forHTTPHeaderField: "accept")
        mutableURLRequest.addValue("application/json", forHTTPHeaderField: "content-type")
        if let parameters = parameters {
            mutableURLRequest.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        }
        
        
        task(mutableURLRequest, completionHandler: completionHandler)
    }
}
