//
//  StoreConfig.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/2/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import Foundation

class StoreConfig: NSObject {
    
    var sessionId: String?
    var sessionExpiry: String?
    var accountKey: String?
    
    var firstName: String?
    var lastName: String?
    
    static let shared: StoreConfig = {
       return StoreConfig()
    }()
}
