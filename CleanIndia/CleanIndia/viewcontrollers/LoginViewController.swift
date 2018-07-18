//
/*
LoginViewController.swift
Created on: 7/18/18

Abstract:
 this controller will allow users to login as well as logout from the App

 note: login is mandatory for adding/removing the toilets 
*/

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
}
