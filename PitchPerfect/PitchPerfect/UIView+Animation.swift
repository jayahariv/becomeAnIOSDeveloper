//
//  UIView+Animation.swift
//  PitchPerfect
//
//  Created by Jayahari Vavachan on 4/8/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

extension UIView {
    // MARK: Animation Helpers
    func fadeOut(after: TimeInterval) {
        self.perform(#selector(fade), with: nil, afterDelay: after)
    }
    
    @objc func fade() {
        self.alpha = 1.0
        UIView.animate(withDuration: 1.5, delay: 0.0, options: [.curveEaseOut, .repeat], animations: {
            self.alpha = 0.0
        }, completion: { _ in
            self.alpha = 0.0
        })
    }
    
    func stopAnimate() {
        self.alpha = 1.0
        UIView.animate(withDuration: 0.0, delay: 0.0, options: [], animations: {
            self.alpha = 0.0
        }, completion: { _ in
            self.alpha = 0.0
        })
    }
    
    func addGlow() {
        self.layer.shadowColor = UIColor.white.cgColor
        self.layer.shadowRadius = 5.0;
        self.layer.shadowOpacity = 1.0;
        self.layer.shadowOffset = CGSize.zero
        self.layer.masksToBounds = false;
    }
    
    func removeGlow() {
        self.layer.shadowOpacity = 0.0;
    }
}
