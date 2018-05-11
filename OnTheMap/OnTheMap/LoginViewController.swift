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
    }
    
    // MARK: Button Actions
    @IBAction func onLogin(_ sender: UIButton) {
        self.performSegue(withIdentifier: "LoginToHome", sender: nil)
//        HttpClient.shared.authenticate(userName: emailTextField.text!, password: passwordTextField.text!) { (success, error) in
//
//        }
    }
    
    @IBAction func onSignUp(_ sender: UIButton) {
        
    }
}

