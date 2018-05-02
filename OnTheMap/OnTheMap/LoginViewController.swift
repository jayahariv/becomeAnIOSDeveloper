//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/1/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HttpClient().get(.udacity, method: HttpConstants.Methods.AuthenticationSession, params: nil) { (result, error) in
            print("first repsonse")
        }
        
        HttpClient().get(.parse, method: HttpConstants.Methods.AuthenticationSession, params: nil) { (resault, error) in
            print("second response")
        }
        
        print()
    }
    
    // MARK: Button Actions
    @IBAction func onLogin(_ sender: UIButton) {
        
    }
    
    @IBAction func onSignUp(_ sender: UIButton) {
        
    }
}

