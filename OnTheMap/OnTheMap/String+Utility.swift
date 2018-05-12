//
//  String+Utility.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/11/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import Foundation

extension String {
    func isValidEmail() -> Bool {
        // username + @ + domain
        let validEmailRegex = "^[A-Za-z0-9._%-+]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", validEmailRegex)
        return emailTest.evaluate(with: self)
    }
    
    func isValidPassword() -> Bool {
        let validPasswordRegex = "^.{7,}$"
        let test = NSPredicate(format: "SELF MATCHES %@", validPasswordRegex)
        return test.evaluate(with: self)
    }
}
