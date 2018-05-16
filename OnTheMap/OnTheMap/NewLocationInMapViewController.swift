//
//  NewLocationInMapViewController.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/16/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

class NewLocationInMapViewController: UIViewController, Alerting {
    var isUpdating: Bool = false
    var location: String!
    var websiteText: String!
    
    fileprivate struct C {
        static let ErrorUpdatingLocation = "Error while updating location"
        static let ErrorAddingLocation = "Error while adding new location"
    }
    
    // MARK: Button Actions
    
    @IBAction func onTouchFinish(_ sender: UIButton) {
        
        if isUpdating {
            HttpClient.shared.updateMyLocation(location, info: websiteText) {[unowned self] (updatedAt, error) in
                if error == nil {
                    self.done()
                } else {
                    self.showError(error, message: C.ErrorUpdatingLocation)
                }
            }
        } else {
            HttpClient.shared.postNewLocation(location, info: websiteText) {[unowned self] (createdAt, error) in
                if error == nil {
                    self.done()
                } else {
                    self.showError(error, message: C.ErrorAddingLocation)
                }
            }
        }
        
        
    }
    
    func done() {
        navigationController?.popToRootViewController(animated: true)
    }
    
}
