//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/10/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, Alerting, HomeNavigationItemsProtocol {
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHomeNavigationBarButtons()
    }
    
    // MARK: Navigation Items Delegate methods
    
    func onLogout() {
        logout()
    }
    
    func onRefresh() {
        print("Refresh from List")
    }
    
    func onAddPin() {
        addLocationPin()
    }
}
