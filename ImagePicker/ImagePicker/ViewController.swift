//
//  ViewController.swift
//  ImagePicker
//
//  Created by Jayahari Vavachan on 4/10/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func experiment(_ sender: UIButton) {
//        Image Picker View
//        let nextViewController = UIImagePickerController()
//        present(nextViewController, animated: true, completion: nil)
     
//        Activity View Controller
//        let image = UIImage()
//        let vc = UIActivityViewController.init(activityItems: [image], applicationActivities: nil)
//        present(vc, animated: true, completion: nil)
        
        let vc = UIAlertController.init(title: "title", message: "message", preferredStyle: .actionSheet)
        let okAction = UIAlertAction.init(title: "OK", style: .default) {[weak self] (action) in
            self?.dismiss(animated: true, completion: nil)
        }
        vc.addAction(okAction)
        present(vc, animated: true, completion: nil)
    }
    
}

