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
        
        StoreConfig.shared.clear()
        HttpClient.shared.authenticate(userName: "abcd@gmail.com", password: "abcd") { (success, error) in
            
            guard
                error != nil,
                success == false,
                StoreConfig.shared.sessionExpiry == nil,
                StoreConfig.shared.sessionId == nil,
                StoreConfig.shared.accountKey == nil
            else {
                XCTFail()
                return
            }
            
            promise.fulfill()
        }
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func testAuthentication() {
        
        let promise = expectation(description: "OnTheMap- Unit Test")
        
        HttpClient.shared.authenticate(userName: "6wypslp86ooc@gmail.com", password: "7Y8NRSlT37kw") { (success, error) in
            
            XCTAssert(error == nil, "Authentication Unit test failed")
            XCTAssert(success == true, "should be successfull")
            
            guard let sessionExpiry = StoreConfig.shared.sessionExpiry else {
                XCTFail("Session Expiry should be present")
                return
            }
            
            
            let sessionExpiryDate = Date.fromStringType2(sessionExpiry)
            XCTAssert(sessionExpiryDate! > Date(), "Expiry date is past time")
            
            promise.fulfill()
        }
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func testLogout() {
        
        let promise = expectation(description: "OnTheMap- Unit Test")
        
        HttpClient.shared.logout() { (success, error) in
            
            XCTAssert(error == nil, "Authentication Unit test failed")
            XCTAssert(success == true, "should be successfull")
            
//            guard let sessionExpiry = StoreConfig.shared.sessionExpiry else {
//                XCTFail("Session Expiry should be present")
//                promise.fulfill()
//                return
//            }
//            
//            let sessionExpiryDate = Date.fromStringType2(sessionExpiry)
////            print(sessionExpiryDate)
//            // check for a 7 hours gap, as the server is showing some error!!!
//            let buffer: Double = 7 * 60 * 60 + 60
//            let futureDate = Date().addingTimeInterval(buffer)
//            print(futureDate)
//            XCTAssert(sessionExpiryDate! < futureDate, "Shouldn't be future time")
            
            promise.fulfill()
        }
        
        waitForExpectations(timeout: 30, handler: nil)
    }
}
