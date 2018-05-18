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
    
    var isUpdating: Bool = false
    var location: String!
    var websiteText: String!
    var locationCoordinate: CLLocationCoordinate2D?
    
    // MARK: Enums
    
    fileprivate struct C {
        static let UpdatingLocationError = "Update Location Error"
        static let AddingLocationError = "Adding Location Error"
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        OnTheMapUtils.getCoordinate(addressString: location) { [unowned self] (coordinate, error) in
            let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0))
            
            DispatchQueue.main.async {
                self.mapView.setRegion(region, animated: true)
                let anotation = StudentLocationAnnotation.init(title: self.location,
                                                               subtitle: self.websiteText,
                                                               coordinate: coordinate)
                self.mapView.addAnnotation(anotation)
            }
            
        }
    }
    
    // MARK: Button Actions
    
    @IBAction func onTouchFinish(_ sender: UIButton) {
        
        if isUpdating {
            HttpClient.shared.updateMyLocation(location, info: websiteText) {[unowned self] (updatedAt, error) in
                if error == nil {
                    self.done()
                } else {
                    self.showError(C.UpdatingLocationError, error: error)
                }
            }
        } else {
            HttpClient.shared.postNewLocation(location, info: websiteText) {[unowned self] (createdAt, error) in
                if error == nil {
                    self.done()
                } else {
                    self.showError(C.AddingLocationError, error: error)
                }
            }
        }
        
        
    }
    
    // MARK: Helper functions
    
    func done() {
        DispatchQueue.main.async { [unowned self] in
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
}
