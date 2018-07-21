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
    
    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
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
    
    
}
