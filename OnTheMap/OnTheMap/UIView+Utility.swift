//
//  UIView+Utility.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/17/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

extension UIView {
    func isVisible() -> Bool {
        func isVisible(_ view: UIView, inView: UIView?) -> Bool {
            guard let inView = inView else { return true }
            let viewFrame = inView.convert(view.bounds, from: view)
            if viewFrame.intersects(inView.bounds) {
                return isVisible(view, inView: inView.superview)
            }
            return false
        }
        return isVisible(self, inView: self.superview)
    }
}
