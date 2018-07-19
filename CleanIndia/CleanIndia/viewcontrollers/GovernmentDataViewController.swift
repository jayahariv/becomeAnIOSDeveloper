//
/*
GovernmentDataViewController.swift
Created on: 7/18/18

Abstract:
 this controller will fetch and display the data from Government

*/

import UIKit

class GovernmentDataViewController: UIViewController {
    
    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
    }
}

// MARK: Private Helper methods

private extension GovernmentDataViewController {
    
    /**
     one time UI setup method when view is finished loading
     */
    func configureUI() {
        
    }
    
    
    /**
     update UI whenever the view is shown
     */
    func updateUI() {
        navigationController?.isNavigationBarHidden = false
    }
}
