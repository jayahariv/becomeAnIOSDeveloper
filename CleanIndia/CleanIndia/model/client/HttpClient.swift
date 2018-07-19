//
/*
HttpClient.swift
Created on: 7/18/18

Abstract:
 use this class when communicating with Http connections.

*/

import Foundation

final class HttpClient: NSObject {
    
    // MARK: properties
    // PUBLIC
    
    /// use this when accessing the httpclient
    var shared: HttpClient {
        return client
    }
    
    // PRIVATE
    private let client: HttpClient = HttpClient()
}
