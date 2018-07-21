//
/*
LoginViewController.swift
Created on: 7/18/18

Abstract:
 this controller will allow users to login as well as logout from the App

 note: login is mandatory for adding/removing the toilets
*/

import UIKit
import FirebaseAuth

final class LoginViewController: UIViewController {
    
    // MARK: Properties
    
    /// PRIVATE
    @IBOutlet weak private var emailAddress: UITextField!
    @IBOutlet weak private var password: UITextField!
    
    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
    }
    
    // MARK: Button Actions
    
    @IBAction func onCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onLogin(_ sender: UIButton) {
        
        // GUARD: checks for valid email address
        guard let emailString = emailAddress.text, let email = validateEmailAddress(emailString) else {
            return
        }
        
        // GUARD: checks for valid password
        guard let pass = password.text else {
            return
        }
        
        login(email, password: pass)
    }
}

// MARK: Private helper functions

private extension LoginViewController {
    
    /**
     one time UI setup is done inside this function. it gets called when view is finished loading.
     */
    func configureUI() {
        // configure here..
    }
    
    
    /**
     update the UI whenever the view is shown.
     */
    func updateUI() {
        navigationController?.isNavigationBarHidden = false
    }
    
    /**
     logs in with the given email address and password. If success show an alert and will dismiss
     - parameters:
        - email: self descriptive
        - password: self descriptive
     */
    func login(_ email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [unowned self] (result, error) in
            guard error == nil else {
                return
            }
            
            let alertvc = UIAlertController(title: "Authentication",
                                            message: "You have successfully logged in.",
                                            preferredStyle: .alert)
            let okay = UIAlertAction(title: "Okay", style: .default, handler: { [unowned self] (_) in
                self.dismiss(animated: true, completion: nil)
            })
            alertvc.addAction(okay)
            self.present(alertvc, animated: true, completion: nil)
        }
    }
    
    /**
     this will validate the passed in string as a valid email address or not. returns the string if its valid email else
     nil.
     */
    func validateEmailAddress(_ email: String) -> String? {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if emailTest.evaluate(with: email) {
            return email
        }
        return nil
    }
}
