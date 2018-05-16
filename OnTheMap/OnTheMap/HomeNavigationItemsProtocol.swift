//
//  UIViewController+Utility.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/11/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

/*
  Home Navigation Items are supported through this protocol.
    * call "addHomeNavigationBarButtons()" in viewDidLoad to add the Home Navigatin Items
    * call "logout()" to logout
 
 */

@objc protocol HomeNavigationItemsProtocol {
    func onLogout()
    func onRefresh()
    func onAddPin()
}

extension HomeNavigationItemsProtocol where Self: UIViewController, Self: Alerting {
    
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
    
    func logout() {
        HttpClient.shared.logout { [unowned self] (success, _) in
            if success {
                DispatchQueue.main.async { [unowned self] in
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                self.showError("Unknown error happened!")
            }
        }
    }
    
    func addLocationPin() {
        let username = (StoreConfig.shared.firstName ?? "_") + " " + (StoreConfig.shared.lastName ?? "_")
        HttpClient.shared.getMyLocation { [unowned self] (locationResults, error) in
            if (locationResults?.results.count ?? 0) > 0 {
                self.showCustomAlert("", message: "User \(username) Has Already Posted a Student Location. Would You Like to Overwrite Their Location?", extraAction: UIAlertAction(title: "Overwrite", style: .default, handler: { (action) in
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddLocationViewController") as! AddLocationViewController
                    self.show(vc, sender: nil)
                }))
            }
        }
    }
}
