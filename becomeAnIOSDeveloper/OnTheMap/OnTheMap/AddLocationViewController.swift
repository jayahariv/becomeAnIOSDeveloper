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
        static let geocodeFetchingError = "Geocordinate Convertion Error"
        static let geocodeNoResultError = "No geo location found for the given string. Please try again"
    }

    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        title = C.title
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: C.leftButtonTitle,
                                                           style: .done,
                                                           target: self,
                                                           action: #selector(onCancel))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unsubscribeKeyboardNotifications()
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
                switch error?.code {
                case CLError.Code.geocodeFoundNoResult.rawValue:
                    self.show(C.geocodeFetchingError, message: C.geocodeNoResultError)
                default:
                    self.showError(C.geocodeFetchingError, error: error)
                }
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

extension AddLocationViewController: UITextFieldDelegate, KeyboardNotificationProtocol {
    func keyboardShown(notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardY = keyboardSize.cgRectValue.origin.y
        let websiteTextFieldY = view.convert(websiteTextField.bounds, from: websiteTextField).origin.y
        if websiteTextField.isFirstResponder && keyboardY < websiteTextFieldY {
            view.frame.origin.y = -(keyboardHeight(notification)/2)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardHide(notification: Notification) {
        view.frame.origin.y = 0
    }
}
