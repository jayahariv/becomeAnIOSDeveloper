//
//  Date+Utility.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/4/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import Foundation

extension Date {
    
    // 2018-05-04T08:12:45.619Z
    static func fromStringType1(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: dateString)
    }
    
    // 2018-07-04T05:58:59.784070Z
    static func fromStringType2(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: dateString)
    }
}
