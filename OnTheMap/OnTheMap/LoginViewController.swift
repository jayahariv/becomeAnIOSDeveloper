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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: Class Constants Enum
    struct C {
        static let title = "Login"
        static let segueToHome = "LoginToHome"
        static let invalidUsernamePasswordMessage = "Email or Password is incorrect. Please try again"
        static let invalidEmailAddress = "Please provide a valid email address."
        static let invalidPassword = "Minimum password length is 7, please check your password."
        static let pageErrorTitle = "Login Error"
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
    
    // MARK: Helper methods
    func clearFields() {
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    func setupUI() {
        title = C.title
    }
    
    func loadingUI(_ loading: Bool) {
        DispatchQueue.main.async { [unowned self] in
            if loading {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
            
            self.loginButton.isEnabled = !loading
            self.emailTextField.isEnabled = !loading
            self.passwordTextField.isEnabled = !loading
        }
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
        
        loadingUI(true)
        HttpClient.shared.authenticate(userName: emailTextField.text!, password: passwordTextField.text!) {[unowned self] (success, error) in
            if success {
                DispatchQueue.main.async { [unowned self] in 
                    self.performSegue(withIdentifier: C.segueToHome, sender: nil)
                }
            } else {
                switch error?.code {
                case HttpErrors.HttpErrorCode.InvalidStatusCode:
                    if
                        let statusCode = error?.userInfo[HttpErrors.UserInfoKeys.statusCode] as? Int,
                        statusCode == HttpConstants.UdacityErrorCode.usernamePasswordIncorrect
                    {
                        self.show(C.pageErrorTitle, message: C.invalidUsernamePasswordMessage)
                    } else {
                        self.show(C.pageErrorTitle, message: Constants.Messages.serverError)
                    }
                default:
                    self.showError(C.pageErrorTitle, error: error)
                }
            }
            
            self.loadingUI(false)
        }
    }
    
    @IBAction func onSignUp(_ sender: UIButton) {
        guard HttpConstants.UdacityConstants.signupURLString.openInSafari() else {
            showAlertMessage(Constants.Messages.invalidURL)
            return
        }
    }
}
