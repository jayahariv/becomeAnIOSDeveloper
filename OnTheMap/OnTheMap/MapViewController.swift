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
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHomeNavigationBarButtons()
        getStudentLocations()
        setupMap()
    }
    
    
    // MARK: Helper methods
    
    func setupMap() {
        // setup whatever for initial 
    }
    
    func getStudentLocations() {
        DispatchQueue.global(qos: .userInitiated).async {
            HttpClient.shared.getStudentLocation(1,
                                                 pageCount: 100,
                                                 sort: StudentLocationSortOrder.inverseUpdatedAt)
            { [unowned self] (result, error) in
                
                guard error == nil else {
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
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? StudentLocationAnnotation else {
            return nil
        }
        
        let identifier = "StudentLocationAnnotationID"
        var view: MKMarkerAnnotationView
        
        if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequedView.annotation = annotation
            view = dequedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .custom)
        }
        return view
    }
}
