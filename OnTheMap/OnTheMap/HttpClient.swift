//
//  HttpClient.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/1/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import Foundation

typealias HTTPCompletionHandler = (_ result: AnyObject?, _ error: NSError?) -> ()

class HttpClient: NSObject {
    
    static let shared: HttpClient = {
       return HttpClient()
    }()
    
    // URL Session Property
    
    private lazy var session: URLSession = {
        return URLSession(configuration: URLSessionConfiguration.default)
    }()
    
    // MARK: ------ Internal APIs ------
    
    // GET request
    func get(_ urlRequest: URLRequest, completionHandler: @escaping HTTPCompletionHandler) {
        task(urlRequest, completionHandler: completionHandler)
    }
    
    // POST, PUT, DELETE tasks can be created using this method
    
    func task(_ httpMethod: String,
              urlRequest: URLRequest,
              body: AnyObject? = nil,
              completionHandler: @escaping HTTPCompletionHandler) {
        
        var mutableURLRequest = urlRequest
        mutableURLRequest.httpMethod = httpMethod
        mutableURLRequest.addValue(HttpConstants.CommonHeaders.applicationJSONValue,
                                   forHTTPHeaderField: HttpConstants.CommonHeaders.acceptKey)
        mutableURLRequest.addValue(HttpConstants.CommonHeaders.applicationJSONValue,
                                   forHTTPHeaderField: HttpConstants.CommonHeaders.contentTypeKey)
        if let body = body {
            mutableURLRequest.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        }
        
        task(mutableURLRequest, completionHandler: completionHandler)
    }
    
    
    // MARK: ------ Helper Methods ------
    
    func urlRequest(_ client: HttpConstants.Clients,
                    path: String,
                    headers: [String: String] = [:],
                    params: [String: AnyObject] = [:]) throws -> URLRequest {
        
        var urlComponents = URLComponents()
        urlComponents.path = path
        
        // Scheme and Host are prepared here
        switch client {
        case .udacity:
            urlComponents.scheme = HttpConstants.UdacityConstants.scheme
            urlComponents.host = HttpConstants.UdacityConstants.host
        case .parse:
            urlComponents.scheme = HttpConstants.ParseConstants.scheme
            urlComponents.host = HttpConstants.ParseConstants.host
        }
        
        // Query Items are prepared here...
        var queryItems = [URLQueryItem]()
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: "\(value)"))
        }
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            throw NSError(domain: HttpErrors.HttpErrorDomain.HTTPGeneralFailure,
                          code: HttpErrors.HttpErrorCode.NoData,
                          userInfo: nil)
        }
        
        var request = URLRequest(url: url)
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
    
    func substitudeKeyInString(_ string: String, key: String, value: String) throws -> String {
        if string.range(of: "{\(key)}") != nil {
            return string.replacingOccurrences(of: "{\(key)}", with: "\(value)")
        }
        throw NSError(domain: HttpErrors.HttpErrorDomain.HTTPGeneralFailure,
                      code: HttpErrors.HttpErrorCode.NoData,
                      userInfo: nil)
    }
}

// MARK: ------ PRIVATE APIs ------

private extension HttpClient {
    
    // Session Task
    private func task(_ urlRequest: URLRequest, completionHandler: @escaping HTTPCompletionHandler) {
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            
            guard error == nil else {
                completionHandler(nil, error! as NSError)
                return
            }
            
            guard data != nil else {
                
                completionHandler(nil, NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                               code: HttpErrors.HttpErrorCode.NoData,
                                               userInfo: nil))
                return
            }
            
            guard
                let statusCode = (response as? HTTPURLResponse)?.statusCode,
                statusCode <= 299, statusCode >= 200
                else {
                    
                    completionHandler(nil, NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                                   code: HttpErrors.HttpErrorCode.InvalidStatusCode,
                                                   userInfo: nil))
                    return
            }
            
            // Remove the first 5 characters from Udacity response data
            var newData = data
            if (response as? HTTPURLResponse)?.url?.host == HttpConstants.UdacityConstants.host {
                let range = Range(5..<data!.count)
                newData = data?.subdata(in: range)
            }
            
            guard
                let serializedData = try? JSONSerialization.jsonObject(with: newData!,
                                                                       options: .allowFragments) as AnyObject
                else {
                    
                    completionHandler(nil, NSError(domain: HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                                   code: HttpErrors.HttpErrorCode.InvalidJSONObject,
                                                   userInfo: nil))
                    return
            }
            
            completionHandler(serializedData, nil)
        }
        
        task.resume()
    }
}
