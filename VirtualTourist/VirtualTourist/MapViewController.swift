//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Jayahari Vavachan on 6/18/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit
import MapKit

/**
 the main view controller, users can
 - add a pin.
 - remove a pin.
 - go to photo album. 
 */

final class MapViewController: UIViewController {
    
    // MARK: Properties
    
    private var pins = [Pin]()
    
    /// constants for this class
    
    private struct C {
        static let annotationViewReusableID = "annotationViewReusableID"
    }

    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        loadPins()
    }
    
    // MARK: Actions
    
    @objc private func onEdit() {
        // TODO: add action when editing
    }
    
    
    // MARK: Convenience
    
    /**
     initial UI is configured here
     
     */
    private func configureUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                            target: self,
                                                            action: #selector(onEdit))
    }
    
    /**
     it will fetch the pins from database and add corresponding annotations to the map.
     
     */
    private func loadPins() {
        // TODO: load pins from db
    }
}

// MARK: MapViewController -> MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var view: MKMarkerAnnotationView
        if let dequedView = mapView.dequeueReusableAnnotationView(
            withIdentifier:C.annotationViewReusableID) as? MKMarkerAnnotationView
        {
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
    
    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        // TODO: go to photo album view controller.
    }
}


