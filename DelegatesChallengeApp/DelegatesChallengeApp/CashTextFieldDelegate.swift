//
//  CashTextFieldDelegate.swift
//  DelegatesChallengeApp
//
//  Created by Jayahari Vavachan on 4/10/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

class CashTextFieldDelegate: NSObject, UITextFieldDelegate {
    var cashInPennies: Int = 0
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) {
            if string.count > 0 {
                cashInPennies = cashInPennies * 10 + Int(string)!
            } else {
                cashInPennies /= 10
            }
            textField.text = "$\(Double(cashInPennies)/100.0)";
        }
        return false;
    }
}
