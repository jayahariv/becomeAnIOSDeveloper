//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/16/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit
import CoreLocation

class AddLocationViewController: UIViewController, Alerting {
    
    // MARK: Properties
    
    var isUpdating: Bool = false
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    
    // MARK: Enums
    struct C {
        static let invalidLocation = "Please provide a valid Location String."
        static let leftButtonTitle = "Cancel"
        static let invalidLocationCoordinate = "Invalid 2D Coordinate. Please try again."
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
            
            guard let coordinate = sender as? CLLocationCoordinate2D else {
                self.showBodyMessage(C.invalidLocationCoordinate)
                return
            }
            
            newLoc?.location = locationTextField.text
            newLoc?.websiteText = websiteTextField.text
            newLoc?.isUpdating = isUpdating
            newLoc?.locationCoordinate = coordinate
        }
    }
    
    // MARK: Button Actions
    
    @objc func onCancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onFindLocation(_ sender: UIButton) {
        
        guard let location = locationTextField.text else {
            showAlertMessage(C.invalidLocation)
            return
        }
        
        guard let websiteText = websiteTextField.text, websiteText.isValidURL() else {
            showAlertMessage(Constants.Messages.invalidURL)
            return
        }
        
        OnTheMapUtils.getCoordinate(addressString: location) { [unowned self] (coordinate, error) in
            guard error == nil else {
                self.showError("Geocordinate Convertion Error", error: error)
                return
            }
            
            guard CLLocationCoordinate2DIsValid(coordinate) else {
                self.showBodyMessage(C.invalidLocationCoordinate)
                return
            }
            
            DispatchQueue.main.async { [unowned self] in
                self.performSegue(withIdentifier: C.segueToMap, sender: coordinate)
            }
        }
    }
}
