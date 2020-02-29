//
//  HttpConstants.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/2/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import Foundation

class HttpConstants: NSObject {
    enum Clients {
        case udacity, parse;
    }
    
    struct CommonHeaders {
        static let contentTypeKey = "Content-type"
        static let acceptKey = "Accept"
        static let applicationJSONValue = "application/json"
    }
    
    struct HTTPMethod {
        static let POST = "POST"
        static let PUT = "PUT"
        static let DELETE = "DELETE"
    }
}
