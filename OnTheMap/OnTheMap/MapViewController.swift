//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/10/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHomeNavigationBarButtons()
    }
}

extension MapViewController: HomeNavigationItemsProtocol {
    func onLogout() {
        print("logout")
    }
    
    func onRefresh() {
        print("refresh")
    }
    
    func onAddPin() {
        print("add pin")
    }
}
