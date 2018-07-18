//
/*
GovernmentDataViewController.swift
Created on: 7/18/18

Abstract:
 this controller will fetch and display the data from Government

*/

import UIKit

class GovernmentDataViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
}
