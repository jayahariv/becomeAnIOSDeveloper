//
//  ZipCodeTextFieldDelegate.swift
//  DelegatesChallengeApp
//
//  Created by Jayahari Vavachan on 4/10/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

class ZipCodeTextFieldDelegate: NSObject, UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = textField.text!.replacingCharacters(in: Range.init(range, in: textField.text!)!, with: string)
        return newText.count <= 5 && CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
    }
}
