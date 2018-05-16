//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/1/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, Alerting {

    // MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: Class Constants Enum
    struct C {
        static let segueToHome = "LoginToHome"
        static let invalidUsernamePasswordMessage = "Email or Password is incorrect. Please try again"
        static let invalidEmailAddress = "Please provide a valid email address."
        static let invalidPassword = "Minimum password length is 7, please check your password."
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearFields()
    }
    
    func setupUI() {
        title = "Login"
    }
    
    // MARK: Helper methods
    func clearFields() {
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    // MARK: Button Actions
    @IBAction func onLogin(_ sender: UIButton) {
        
        guard let emailAddress = emailTextField.text, emailAddress.isValidEmail() else {
            showAlertMessage(C.invalidEmailAddress)
            return
        }
        
        guard let password = passwordTextField.text, password.isValidPassword() else {
            showAlertMessage(C.invalidPassword)
            return
        }
        
        HttpClient.shared.authenticate(userName: emailTextField.text!, password: passwordTextField.text!) {[unowned self] (success, error) in
            if success {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: C.segueToHome, sender: nil)
                }
            } else {
                switch error?.code {
                case HttpErrors.HttpErrorCode.InvalidStatusCode:
                    if
                        let statusCode = error?.userInfo[HttpErrors.UserInfoKeys.statusCode] as? Int,
                        statusCode == HttpConstants.UdacityErrorCode.usernamePasswordIncorrect
                    {
                        self.showAlertMessage(C.invalidUsernamePasswordMessage)
                    }
                default:
                    self.showError(error, message: "Unknown error happened. Please try again")
                }
            }
        }
    }
    
    @IBAction func onSignUp(_ sender: UIButton) {
        guard HttpConstants.UdacityConstants.signupURLString.openInSafari() else {
            showAlertMessage("Invalid Link")
            return
        }
    }
}
