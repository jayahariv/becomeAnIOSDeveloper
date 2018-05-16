//
//  AlertingProtocol.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/11/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

protocol Alerting { }

extension Alerting where Self: UIViewController {
    
    // it will show an alert message with page title
    func showAlertMessage(_ message: String) {
        showCustomAlert(self.title, message: message, extraAction: nil)
    }
    
    func showBodyMessage(_ message: String) {
        showCustomAlert("", message: message, extraAction: nil)
    }
    
    func showError(_ error: NSError?, message: String) {
        showCustomAlert(String(error?.code ?? 0), message: "\(message) \(error?.description ?? "")", extraAction: nil)
    }
    
    func showCustomAlert(_ title: String?, message: String, extraAction: UIAlertAction?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            if let extraAction = extraAction {
                alert.addAction(extraAction)
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
