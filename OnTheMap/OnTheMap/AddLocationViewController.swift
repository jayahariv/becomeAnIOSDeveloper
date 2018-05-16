//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/16/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

class AddLocationViewController: UIViewController {
    
    override func viewDidLoad() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancel))
    }
    
    @objc func cancel() {
        navigationController?.popViewController(animated: true)
    }
}
