//
//  HttpClient+Parse.swift
//  OnTheMapTests
//
//  Created by Jayahari Vavachan on 5/3/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import XCTest

@testable import OnTheMap

class HttpClient_Parse: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNoStudentLocation() {
        
        let promise = expectation(description: "OnTheMap- Unit Test")
        
        HttpClient.shared.getStudentLocation(0, pageCount: 0, sort: StudentLocationSortOrder.inverseUpdatedAt) { (result, error) in
            XCTAssert(error == nil, "No Error should happen")
            XCTAssert(result != nil, "Student Location UNit test failed!!")
            XCTAssert(result?.count == 0, "Student Location UNit test failed!!")
            promise.fulfill()
        }
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func testStudentLocation() {
        
        let promise = expectation(description: "OnTheMap- Unit Test")
        
        HttpClient.shared.getStudentLocation(1, pageCount: 20, sort: StudentLocationSortOrder.inverseUpdatedAt) { (result, error) in
            
            XCTAssert(error == nil, "No Error should happen")
            XCTAssert(result != nil, "Student Location UNit test failed!!")
            XCTAssert(result?.count == 20, "Student Location UNit test failed!!")
            promise.fulfill()
        }
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func testMyLocationNoData() {
        
        let promise = expectation(description: "OnTheMap- Unit Test")
        
        StoreConfig.shared.accountKey = "11470468759"
        HttpClient.shared.getMyLocation() { (result, error) in
            
            XCTAssert(error == nil, "No Error should happen")
            XCTAssert(result != nil, "Student Location result empty!!")
            XCTAssert(result?.count == 0, "Student Location result is having list")
            promise.fulfill()
        }
        
        waitForExpectations(timeout: 30, handler: nil)
    }
}
