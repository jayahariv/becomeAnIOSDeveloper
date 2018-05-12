//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/12/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit
import CoreLocation

/*
 
 SAMPLE PAYLOAD
 
 "createdAt": "2015-02-25T01:10:38.103Z",
 "firstName": "Jarrod",
 "lastName": "Parkes",
 "latitude": 34.7303688,
 "longitude": -86.5861037,
 "mapString": "Huntsville, Alabama ",
 "mediaURL": "https://www.linkedin.com/in/jarrodparkes",
 "objectId": "JhOtcRkxsh",
 "uniqueKey": "996618664",
 "updatedAt": "2015-03-09T22:04:50.315Z"
 
 */

struct StudentLocationResults: Codable {
    var results: [StudentLocation]
}

struct StudentLocation: Codable {
    var firstName: String?
    var lastName: String?
    var mediaURL: String?
    var latitude: Double?
    var longitude: Double?
}
