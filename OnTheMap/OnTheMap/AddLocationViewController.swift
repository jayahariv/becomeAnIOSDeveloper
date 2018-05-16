//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/16/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

class AddLocationViewController: UIViewController, Alerting {
    
    // MARK: Properties
    
    var isUpdating: Bool = false
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    
    // MARK: Enums
    struct C {
        static let invalidLocation = "Please provide a valid Location String."
        static let invalidURL = "Please provide a valid URL."
        static let leftButtonTitle = "Cancel"
        static let segueToMap = "AddLocationToMap"
        static let title = "Add Location"
    }

    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        title = C.title
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: C.leftButtonTitle,
                                                           style: .done,
                                                           target: self,
                                                           action: #selector(onCancel))
    }
    
    // Is there any issue in taking value directy from textfield? can we pass the validated data directly to here?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == C.segueToMap {
            let newLoc = segue.destination as? NewLocationInMapViewController
            newLoc?.location = locationTextField.text
            newLoc?.websiteText = websiteTextField.text
            newLoc?.isUpdating = isUpdating
        }
    }
    
    // MARK: Button Actions
    
    @objc func onCancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onFindLocation(_ sender: UIButton) {
        
        guard locationTextField.text != nil else {
            showAlertMessage(C.invalidLocation)
            return
        }
        
        guard let websiteText = websiteTextField.text, websiteText.isValidURL() else {
            showAlertMessage(C.invalidURL)
            return
        }
        
        self.showLocationOnMap()
    }
    
    // MARK: Helper functions
    
    func showLocationOnMap() {
        DispatchQueue.main.async { [unowned self] in
            self.performSegue(withIdentifier: C.segueToMap, sender: nil)
        }
    }
}
