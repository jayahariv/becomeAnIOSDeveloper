//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/10/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        addHomeNavigationBarButtons()
    }
}

extension ListViewController: HomeNavigationItemsProtocol {
    func onLogout() {
        print("Logout from List")
    }
    
    func onRefresh() {
        print("Refresh from List")
    }
    
    func onAddPin() {
        print("Add pin from List")
    }
}
