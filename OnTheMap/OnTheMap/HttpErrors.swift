//
//  HttpErrors.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/1/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import Foundation

/*
    HttpErrors will list a predefined errors commonly happen in this application.
    It will contain domains, codes, info-keys
 */

class HttpErrors {
    
    struct HttpErrorDomain {
        
        /* all the error which will happen when any URLSession task fails */
        static let URLSessionTaskFailure = "URLSessionTaskFailure"
        
        static let HTTPGeneralFailure = "HTTPGeneralFailure"
    }
    
    // common error codes are predefined
    struct HttpErrorCode {
        static let ErrorNotEmpty = 1_1001
        static let NoData = 1_1002
        static let InvalidStatusCode = 1_1003
        static let InvalidJSONObject = 1_1004
        static let InvalidType = 1_1005
        
        static let RequestCreationError = 2_1001
    }
}
