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
    
    // POST request
    func post(_ urlRequest: URLRequest,
              parameters: [String: AnyObject]?,
              completionHandler: @escaping HTTPCompletionHandler) {
        
        var mutableURLRequest = urlRequest
        mutableURLRequest.httpMethod = "POST"
        
        jsonTaskWithParameters(mutableURLRequest, parameters: parameters, completionHandler: completionHandler)
    }
    
    // PUT request
    func put(_ urlRequest: URLRequest,
              parameters: [String: AnyObject]?,
              completionHandler: @escaping HTTPCompletionHandler) {
        
        var mutableURLRequest = urlRequest
        mutableURLRequest.httpMethod = "PUT"
        
        jsonTaskWithParameters(mutableURLRequest, parameters: parameters, completionHandler: completionHandler)
    }
    
    // MARK: ------ Helper Methods ------
    
    func urlRequest(_ client: HttpConstants.Clients,
                    path: String,
                    headers: [String: String] = [:],
                    params: [String: AnyObject] = [:]) -> URLRequest? {
        
        var urlComponents = URLComponents()
        switch client {
        case .udacity:
            urlComponents.scheme = HttpConstants.UdacityConstants.scheme
            urlComponents.host = HttpConstants.UdacityConstants.host
        case .parse:
            urlComponents.scheme = HttpConstants.ParseConstants.scheme
            urlComponents.host = HttpConstants.ParseConstants.host
        }
        
        urlComponents.path = path
        
        var queryItems = [URLQueryItem]()
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: "\(value)"))
        }
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
    
    func finish(_ domain: String?, code: Int, info: [String : Any]? = nil, completionHandler: HTTPCompletionHandler?) {
        
        let error = NSError(domain: domain ?? HttpErrors.HttpErrorDomain.HTTPGeneralFailure, code: code, userInfo: info)
        
        completionHandler?(nil, error)
    }
    
    func substitudeKeyInString(_ string: String, key: String, value: String) -> String? {
        if string.range(of: "{\(key)}") != nil {
            return string.replacingOccurrences(of: "{\(key)}", with: "\(value)")
        }
        return nil
    }
}

// MARK: ------ PRIVATE APIs ------

private extension HttpClient {
    
    // Session Task
    private func task(_ urlRequest: URLRequest, completionHandler: @escaping HTTPCompletionHandler) {
        
        let task = session.dataTask(with: urlRequest) { [unowned self] (data, response, error) in
            
            guard error == nil else {
                self.finish(HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                            code: HttpErrors.HttpErrorCode.ErrorNotEmpty,
                            info: (error as? URLError)?.userInfo,
                            completionHandler: completionHandler)
                return
            }
            
            guard data != nil else {
                self.finish(HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                            code: HttpErrors.HttpErrorCode.NoData,
                            info: (error as? URLError)?.userInfo,
                            completionHandler: completionHandler)
                return
            }
            
            guard
                let statusCode = (response as? HTTPURLResponse)?.statusCode,
                statusCode <= 299, statusCode >= 200
                else {
                    
                    self.finish(HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                code: HttpErrors.HttpErrorCode.InvalidStatusCode,
                                info: (error as? URLError)?.userInfo,
                                completionHandler: completionHandler)
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
                    self.finish(HttpErrors.HttpErrorDomain.URLSessionTaskFailure,
                                code: HttpErrors.HttpErrorCode.InvalidJSONObject,
                                completionHandler: completionHandler)
                    return
            }
            
            completionHandler(serializedData, nil)
        }
        
        task.resume()
    }
    
    // session task with parameters
    
    func jsonTaskWithParameters(_ urlRequest: URLRequest,
                                parameters: [String: AnyObject]?,
                                completionHandler: @escaping HTTPCompletionHandler) {
        var mutableURLRequest = urlRequest
        mutableURLRequest.addValue("application/json", forHTTPHeaderField: "accept")
        mutableURLRequest.addValue("application/json", forHTTPHeaderField: "content-type")
        if let parameters = parameters {
            mutableURLRequest.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        }
        
        
        task(mutableURLRequest, completionHandler: completionHandler)
    }
}
