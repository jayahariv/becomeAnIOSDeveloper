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
        static let PublicUserData = "/api/users/{user_id}"
    }
    
    struct UdacityParameterKeys {
        
        // new session
        static let udacity = "udacity";
        static let username = "username";
        static let password = "password";
        
        static let publicUserDataIDKey = "user_id"
    }
    
    struct UdacityResponseKeys {
        
        // new session
        static let session = "session"
        static let sessionId = "id"
        static let sessionExpiry = "expiration"
        static let account = "account"
        static let accountKey = "key"
        
        static let user = "user"
        static let firstName = "first_name"
        static let lastName = "last_name"
    }
}
