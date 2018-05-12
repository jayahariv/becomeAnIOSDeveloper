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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHomeNavigationBarButtons()
    }
}

extension MapViewController: HomeNavigationItemsProtocol {
    func onLogout() {
        logout()
    }
    
    func onRefresh() {
        print("refresh")
    }
    
    func onAddPin() {
        print("add pin")
    }
}
