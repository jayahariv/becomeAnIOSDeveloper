//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/10/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, Alerting {
    
    var alertTitle: String = "Map View Page Alert"
    
    var alertButtonTitle: String = "Cancel"
    
    struct C {
        static let logoutFailedMessage = "Something went wrong. Please try again"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHomeNavigationBarButtons()
    }
}

extension MapViewController: HomeNavigationItemsProtocol {
    func onLogout() {
        HttpClient.shared.logout { [unowned self] (success, _) in
            if success {
                DispatchQueue.main.async { [unowned self] in 
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                self.showError(C.logoutFailedMessage)
            }
        }
    }
    
    func onRefresh() {
        print("refresh")
    }
    
    func onAddPin() {
        print("add pin")
    }
}
