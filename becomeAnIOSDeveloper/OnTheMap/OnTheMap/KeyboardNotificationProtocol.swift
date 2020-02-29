//
//  KeyboardNotificationProtocol.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/17/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

@objc protocol KeyboardNotificationProtocol where Self: UITextFieldDelegate {
    func keyboardShown(notification: Notification)
    func keyboardHide(notification: Notification)
}


extension KeyboardNotificationProtocol {
    
    func subscribeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
}
