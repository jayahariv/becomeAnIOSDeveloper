//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Jayahari Vavachan on 6/18/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    /// datacontroller instance for the app.
    let dataController = DataController("virtual_tourist")


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // initialize the core data
        dataController.load()
        
        // inject the datacontroller
        let navigationController = window?.rootViewController as! UINavigationController
        let mapView = navigationController.topViewController as! MapViewController
        mapView.dataController = dataController
        
        return true
    }
}

