//
//  UIViewController+Utility.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/11/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

@objc protocol HomeNavigationItemsProtocol {
    func onLogout()
    func onRefresh()
    func onAddPin()
}

extension HomeNavigationItemsProtocol where Self: UIViewController {
    
    func addHomeNavigationBarButtons() {
        let logoutButton = UIBarButtonItem(title: "Logout",
                                           style: .plain,
                                           target: self,
                                           action: #selector(self.onLogout))
        navigationItem.leftBarButtonItem = logoutButton
        
        let refreshButton = UIBarButtonItem(image: UIImage(named: "icon_refresh"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(self.onRefresh))
        let addPinButton = UIBarButtonItem(image: UIImage(named: "icon_addpin"),
                                           style: .plain,
                                           target: self,
                                           action: #selector(self.onAddPin))
        
        navigationItem.rightBarButtonItems = [
            addPinButton,
            refreshButton
        ]
    }
}
