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
    
    func showError(_ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: self.title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
