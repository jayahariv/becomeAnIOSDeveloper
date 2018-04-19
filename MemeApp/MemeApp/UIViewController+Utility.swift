//
//  UIViewController+Utility.swift
//  MemeApp
//
//  Created by Jayahari Vavachan on 4/19/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // MARK: this memes will be avilable to all classes as properties
    
    var memes: [Meme] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.memes
    }
    
    // MARK: Helper methods
    
    func removeMeme(at index: Int) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memes.remove(at: index)
    }
}
