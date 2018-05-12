//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/10/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, Alerting {
    var alertTitle: String = "List Page Alert"
    
    var alertButtonTitle: String = "Cancel"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHomeNavigationBarButtons()
    }
}

extension ListViewController: HomeNavigationItemsProtocol {
    func onLogout() {
        logout()
    }
    
    func onRefresh() {
        print("Refresh from List")
    }
    
    func onAddPin() {
        print("Add pin from List")
    }
}
