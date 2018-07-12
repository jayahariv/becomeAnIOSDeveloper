//
/*
AppDelegate.swift
Created on: 7/3/18

Abstract:
TODO: Purpose of file

*/

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        // configures firebase
        FirebaseApp.configure()
        
        return true
    }
}

