//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/1/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import Foundation

extension HttpConstants {
    
    static func udacitySchema() -> String {
        return "https"
    }
    static func udacityHost() -> String {
        return "www.udacity.com"
    }
    
    struct Methods {
        static let AuthenticationSession = "api/session";
    }
    
    struct ParameterKeys {
        static let udacity = "udacity";
        static let username = "username";
        static let password = "password";
    }
}
