//
//  UIView+Configuration.swift
//  PitchPerfect
//
//  Created by Jayahari Vavachan on 4/8/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

extension UIView {
    func circleSetup() {
        makeCircle()
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.borderColor.cgColor
        self.alpha = 0.0
    }
    
    func makeCircle() {
        self.layer.cornerRadius = self.frame.size.width/2.0
    }
}
