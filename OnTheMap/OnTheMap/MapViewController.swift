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
    // iVars
    var studentLocationAnnotations = [StudentLocationAnnotation]()
    
    fileprivate struct C {
        static let annotationViewReusableID = "StudentLocationAnnotationID"
        static let title = "One the Map"
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHomeNavigationBarButtons()
        getStudentLocations()
        setupUI()
    }
    
    
    // MARK: Helper methods
    
    func setupUI() {
        title = C.title
    }
    
    func getStudentLocations() {
        DispatchQueue.global(qos: .userInitiated).async {
            HttpClient.shared.getStudentLocation(1,
                                                 pageCount: 100,
                                                 sort: StudentLocationSortOrder.inverseUpdatedAt)
            { [unowned self] (result, error) in
                
                guard error == nil else {
                    self.showError("Fetch Student Location Error", error: error)
                    return
                }
                
                for loc in result?.results ?? [] {
                    if let anotation = StudentLocationAnnotation.init(loc) {
                        self.studentLocationAnnotations.append(anotation)
                    }
                }
                
                DispatchQueue.main.async {
                    self.mapView.addAnnotations(self.studentLocationAnnotations)
                }
            }
        }
    }
    
    // MARK: Navigation Items Delegate Methods
    
    func onLogout() {
        logout()
    }
    
    func onRefresh() {
        getStudentLocations()
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
