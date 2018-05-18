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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var findLocationButton: UIButton!
    
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
    
    // MARK: helper methods
    
    func loadingUI(_ loading: Bool) {
        DispatchQueue.main.async { [unowned self] in 
            if loading {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
            self.locationTextField.isEnabled = !loading
            self.websiteTextField.isEnabled = !loading
            self.findLocationButton.isEnabled = !loading
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
        
        loadingUI(true)
        OnTheMapUtils.getCoordinate(addressString: location) { [unowned self] (coordinate, error) in
            
            self.loadingUI(false)
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
