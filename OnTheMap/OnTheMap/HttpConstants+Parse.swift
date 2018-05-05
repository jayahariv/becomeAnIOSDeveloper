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
        static let applicationJSON = "application/json"
    }
    
    struct ParseMethods {
        static let studentsLocation = "/parse/classes/StudentLocation"
        static let updateStudentLocation = "/parse/classes/StudentLocation/{location}"
    }
    
    struct ParseHeaderKeys {
        static let applicationId = "X-Parse-Application-Id"
        static let restApiKey = "X-Parse-REST-API-Key"
        static let contentType = "content-type"
    }
    
    struct ParseParameterKeys {
        static let limit = "limit"
        static let skip = "skip"
        static let order = "order"
        static let uniqueKeyString = "{\"uniqueKey\":\"{key}\"}"
        static let uniqueKey = "key"
        static let `where` = "where"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let mapString = "mapString"
        static let mediaURL = "mediaURL"
        static let latitude = "latitude"
        static let longitude = "longitude"
        
        // uses to update the key through substitude method
        static let updateStudentLocationKey = "location"
    }
    
    struct ParseResponseKeys {
        static let results = "results"
        static let createdAt = "createdAt"
        static let objectId = "objectId"
    }
}
