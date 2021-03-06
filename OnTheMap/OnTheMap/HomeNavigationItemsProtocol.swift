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

fileprivate struct C {
    static let UnknownError = "Unknown error happened!"
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
                self.showAlertMessage(C.UnknownError)
            }
        }
    }
    
    func showAddLocation(_ updating: Bool = false) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: AddLocationViewController.self)) as! AddLocationViewController
        vc.isUpdating = updating
        self.show(vc, sender: nil)
    }
    
    func addLocationPin() {
        let username = (StoreConfig.shared.firstName ?? "_") + " " + (StoreConfig.shared.lastName ?? "_")
        let message = "User \(username) Has Already Posted a Student Location. Would You Like to Overwrite Their Location?"
        HttpClient.shared.getMyLocation { [unowned self] (locationResults, error) in
            if (locationResults?.results.count ?? 0) > 0 {
                StoreConfig.shared.locationObjectId = locationResults?.results.first?.objectId
                self.showCustomAlert("",
                                     message: message,
                                     extraAction: UIAlertAction(title: "Overwrite",
                                                                style: .default,
                                                                handler: { [unowned self] (action) in
                                                                    self.showAddLocation(true)
                                                                })
                )
            } else {
                self.showAddLocation()
            }
        }
    }
    
    // loads the student locations from the server to the StoreConfig
    func loadStudentLocations(completion: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            HttpClient.shared.getStudentLocation(1,
                                                 pageCount: 100,
                                                 sort: StudentLocationSortOrder.inverseUpdatedAt)
            { (result, error) in
                
                guard error == nil else {
                    completion(false, error)
                    return
                }
                
                StoreConfig.shared.studentLocationResults = result?.results ?? []
                
                completion(true, nil)
            }
        }
    }
}
