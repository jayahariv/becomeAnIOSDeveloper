//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/10/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, Alerting, HomeNavigationItemsProtocol {
    
    // MARK: Properties
    
    // IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    fileprivate struct C {
        static let annotationViewReusableID = "StudentLocationAnnotationID"
        static let title = "One the Map"
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHomeNavigationBarButtons()
        setupUI()
        loadStudents()
    }
    
    
    // MARK: Helper methods
    
    func setupUI() {
        title = C.title
    }
    
    func loadStudents() {
        
        activityIndicator.startAnimating()
        loadStudentLocations {[unowned self] (success, error) in
            
            DispatchQueue.main.async { [unowned self] in 
                self.activityIndicator.stopAnimating()
            }
            
            guard error == nil && success == true else {
                self.showError("Student Location Loading", error: error)
                return
            }
            
            var annotations = [StudentLocationAnnotation]()
            for loc in StoreConfig.shared.studentLocationResults {
                if let anotation = StudentLocationAnnotation.init(loc) {
                    annotations.append(anotation)
                }
            }
            
            DispatchQueue.main.async { [unowned self] in
                self.mapView.addAnnotations(annotations)
            }
        }
    }
    
    // MARK: Navigation Items Delegate Methods
    
    func onLogout() {
        logout()
    }
    
    func onRefresh() {
        loadStudents()
    }
    
    func onAddPin() {
        addLocationPin()
    }
    
    func onCancel() {
        navigationController?.popViewController(animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? StudentLocationAnnotation else {
            return nil
        }
        
        var view: MKMarkerAnnotationView
        if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: C.annotationViewReusableID) as? MKMarkerAnnotationView {
            dequedView.annotation = annotation
            view = dequedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: C.annotationViewReusableID)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .infoDark)
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if !(view.annotation?.subtitle??.openInSafari() ?? false) {
            showBodyMessage(Constants.Messages.invalidURL)
        }
    }
}
