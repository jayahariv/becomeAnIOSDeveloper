//
//  HttpClient+Udacity.swift
//  OnTheMapTests
//
//  Created by Jayahari Vavachan on 5/3/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import XCTest

@testable import OnTheMap

class HttpClient_Udacity: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFailedAuthentication() {
        
        let promise = expectation(description: "OnTheMap- Unit Test")
        
        HttpClient.shared.authenticate(userName: "abcd@gmail.com", password: "abcd") { (sessionId, sessionExpiry, error) in
            XCTAssert(error != nil, "Authentication Unit test failed")
            XCTAssert(sessionId == nil, "Needed a valid sessionID")
            XCTAssert(sessionExpiry == nil, "Needed a valid session expiry")
            promise.fulfill()
        }
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func testAuthentication() {
        
        let promise = expectation(description: "OnTheMap- Unit Test")
        
        HttpClient.shared.authenticate(userName: "6wypslp86ooc@gmail.com", password: "7Y8NRSlT37kw") { (sessionId, sessionExpiry, error) in
            XCTAssert(error == nil, "Authentication Unit test failed")
            XCTAssert(sessionId != nil, "Needed a valid sessionID")
            
            guard sessionExpiry != nil else {
                XCTFail("Session Expiry should be present")
                promise.fulfill()
                return
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            
            let sessionExpiryDate = dateFormatter.date(from:sessionExpiry!)
            XCTAssert(sessionExpiryDate! > Date(), "Expiry date is past time")
            
            promise.fulfill()
        }
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
}
