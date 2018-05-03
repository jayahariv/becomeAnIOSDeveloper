//
//  HttpConstants+Udacity.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/1/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import Foundation

extension HttpConstants {
    
    struct UdacityConstants {
        static let scheme = "https";
        static let host = "www.udacity.com"
    }
    
    struct UdacityMethods {
        
        static let AuthenticationSession = "/api/session";
    }
    
    struct UdacityParameterKeys {
        
        // new session
        static let udacity = "udacity";
        static let username = "username";
        static let password = "password";
    }
    
    struct UdacityResponseKeys {
        
        // new session
        static let session = "session"
        static let sessionId = "id"
        static let sessionExpiry = "expiration"
    }
}
