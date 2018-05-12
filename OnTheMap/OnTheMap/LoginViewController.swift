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
    
    // MARK: Class Constants Enum
    struct C {
        static let segueToHome = "LoginToHome"
        static let errorPageTitle = "Login Page Error"
        static let errorButtonTitle = "Cancel"
        static let invalidUsernamePasswordMessage = "Email or Password is incorrect. Please try again"
        static let invalidEmailAddress = "Please provide a valid email address."
        static let invalidPassword = "Minimum password length is 7, please check your password."
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Button Actions
    @IBAction func onLogin(_ sender: UIButton) {
        
        guard let emailAddress = emailTextField.text, emailAddress.isValidEmail() else {
            showError(C.invalidEmailAddress)
            return
        }
        
        guard let password = passwordTextField.text, password.isValidPassword() else {
            showError(C.invalidPassword)
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
                        self.showError(C.invalidUsernamePasswordMessage)
                    }
                default:
                    self.showError("Unknown error happened(\(error?.code ?? 0)). Please try again")
                }
            }
        }
    }
    
    @IBAction func onSignUp(_ sender: UIButton) {
        
    }
    
    // MARK: Helper methods
    func showError(_ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: C.errorPageTitle, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: C.errorButtonTitle, style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
