//
//  UIViewController+NavigationBar.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/11/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

extension UIViewController {
    
    final public class func swizzle() {
        
        guard self == UIViewController.self else {
            return
        }
        
        let originalSelector = #selector(UIViewController.viewWillAppear(_:))
        let swizzledSelector = #selector(self.swizzledViewWillAppear(_:))
        
        guard
            let originalMethod = class_getInstanceMethod(self, originalSelector),
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        else {
            return
        }
        
        let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        if didAddMethod {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    
    @objc func swizzledViewWillAppear(_ animated: Bool) {
        self.swizzledViewWillAppear(animated)
        print("Hellow Hwlloe")
    }
}
