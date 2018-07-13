//
/*
Constants.swift
Created on: 7/11/18

Abstract:
 self descriptive

*/

import Foundation

struct Constants {
    struct Firestore {
        struct Keys {
            static let TOILETS = "toilets"
            static let NAME = "name"
            static let RATING = "rating"
            static let ADDRESS = "address"
            static let COORDINATE = "coordinate"
        }
    }
    
    struct India {
        struct FullViewCoordinates {
            static let latitude: Double = 23.5000941
            static let longitude: Double = 83.3512675
            static let delta: Double  = 30.0
        }
    }
    
    struct Kerala {
        struct FullViewCoordinates {
            static let latitude: Double = 10.6515143
            static let longitude: Double = 76.5534489
            static let delta: Double = 4.0
        }
    }
}
