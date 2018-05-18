//
//  NewLocationInMapViewController.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/16/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit
import MapKit

class NewLocationInMapViewController: UIViewController, Alerting {
    // MARK: Properties
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var finishButton: UIButton!
    
    var isUpdating: Bool = false
    var location: String!
    var websiteText: String!
    var locationCoordinate: CLLocationCoordinate2D!
    
    // MARK: Enums
    
    fileprivate struct C {
        static let UpdatingLocationError = "Update Location Error"
        static let AddingLocationError = "Adding Location Error"
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        setupUI()
    }
    
    // MARK: Helper methods
    func loadingUI(_ loading: Bool) {
        DispatchQueue.main.async { [unowned self] in
            if loading {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
            
            self.finishButton.isEnabled = !loading
        }
    }
    
    // MARK: Button Actions
    
    @IBAction func onTouchFinish(_ sender: UIButton) {
        
        loadingUI(true)
        if isUpdating {
            HttpClient.shared.updateMyLocation(location, info: websiteText) {[unowned self] (updatedAt, error) in
                
                self.loadingUI(false)
                if error == nil {
                    self.done()
                } else {
                    switch error?.code {
                    case HttpErrors.HttpErrorCode.InvalidStatusCode:
                        self.show(C.UpdatingLocationError, message: Constants.Messages.serverError)
                    default:
                        self.showError(C.UpdatingLocationError, error: error)
                    }
                }
            }
        } else {
            HttpClient.shared.postNewLocation(location, info: websiteText) {[unowned self] (createdAt, error) in
                
                self.loadingUI(false)
                if error == nil {
                    self.done()
                } else {
                    switch error?.code {
                    case HttpErrors.HttpErrorCode.InvalidStatusCode:
                        self.show(C.AddingLocationError, message: Constants.Messages.serverError)
                    default:
                        self.showError(C.AddingLocationError, error: error)
                    }
                }
            }
        }
        
        
    }
    
    // MARK: Helper functions
    
    func setupUI() {
        let region = MKCoordinateRegion(center: locationCoordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0))
        
        self.mapView.setRegion(region, animated: true)
        let anotation = StudentLocationAnnotation.init(title: self.location,
                                                       subtitle: self.websiteText,
                                                       coordinate: locationCoordinate)
        self.mapView.addAnnotation(anotation)
    }
    
    func done() {
        DispatchQueue.main.async { [unowned self] in
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
}
