//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/10/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, Alerting, HomeNavigationItemsProtocol {
    var studentLocationResults: StudentLocationResults?
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHomeNavigationBarButtons()
        getStudentLocations()
    }
    
    func getStudentLocations() {
        DispatchQueue.global(qos: .userInitiated).async {
            HttpClient.shared.getStudentLocation(1,
                                                 pageCount: 100,
                                                 sort: StudentLocationSortOrder.inverseUpdatedAt) {[unowned self] (result, error) in
                
                guard error == nil else {
                    return
                }
                
                self.studentLocationResults = result
            }
        }
    }
    
    // MARK: Navigation Items Delegate Methods
    
    func onLogout() {
        logout()
    }
    
    func onRefresh() {
        getStudentLocations()
    }
    
    func onAddPin() {
        addLocationPin()
    }
}
