//
//  HttpConstants+Parse.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/1/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import Foundation

extension HttpConstants {
    
    struct ParseConstants {
        static let scheme = "https";
        static let host = "parse.udacity.com"
        static let AppId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RestApiId = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
    
    struct ParseMethods {
        static let studentsLocation = "/parse/classes/StudentLocation"
    }
    
    struct ParseHeaderKeys {
        static let applicationId = "X-Parse-Application-Id"
        static let restApiKey = "X-Parse-REST-API-Key"
    }
    
    struct ParseParameterKeys {
        static let limit = "limit"
        static let skip = "skip"
        static let order = "order"
    }
    
    struct ParseResponseKeys {
        static let results = "results"
    }
}
