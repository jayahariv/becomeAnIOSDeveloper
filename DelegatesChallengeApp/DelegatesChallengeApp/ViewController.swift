//
//  ViewController.swift
//  DelegatesChallengeApp
//
//  Created by Jayahari Vavachan on 4/10/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: properties
    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var cashTextField: UITextField!
    @IBOutlet weak var locableTextField: UITextField!
    
    var locableTextFieldEditable: Bool = true
    let zipCodeTextFieldDelegate = ZipCodeTextFieldDelegate()
    let cashTextFieldDelegate = CashTextFieldDelegate()
    
    // MARK: lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        zipCodeTextField.delegate = zipCodeTextFieldDelegate
        cashTextField.delegate = cashTextFieldDelegate
    }

    // MARK: button actions
    @IBAction func onToggleLock(_ sender: UISwitch) {
        locableTextFieldEditable = sender.isOn
    }
}

extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return locableTextFieldEditable
    }
}

