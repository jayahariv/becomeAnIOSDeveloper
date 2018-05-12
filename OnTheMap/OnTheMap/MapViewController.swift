//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/10/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, Alerting, HomeNavigationItemsProtocol {
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHomeNavigationBarButtons()
    }
    
    // MARK: Navigation Items Delegate Methods
    
    func onLogout() {
        logout()
    }
    
    func onRefresh() {
        print("refresh")
    }
    
    func onAddPin() {
        addLocationPin()
    }
}
