//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Jayahari Vavachan on 6/18/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

/**
 the main view controller, users can
 - add a pin.
 - remove a pin.
 - go to photo album. 
 */

final class MapViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var mapView: MKMapView!
    
    private var pins = [Pin]()
    
    /// constants for this class
    
    private struct C {
        static let annotationViewReusableID = "annotationViewReusableID"
        static let unknownLocationTitle = "Unknown location"
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
    
    @objc private func onLongPress(_ gesture: UIGestureRecognizer) {
        if gesture.state == .ended {
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            addAnnotation(coordinate)
        }
    }
    
    
    // MARK: Convenience
    
    /**
     initial UI is configured here
     
     */
    private func configureUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                            target: self,
                                                            action: #selector(onEdit))
        // add long press gesture recognizer.
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:)))
        longPressGesture.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    /**
     it will fetch the pins from database and add corresponding annotations to the map.
     
     */
    private func loadPins() {
        // TODO: load pins from db
    }
    
    /**
     
     add annotation to the map & verify first whether the coordinates is valid.
     
     - parameters:
        - coordinate: coordinates for the annotation
     */
    func addAnnotation(_ coordinate: CLLocationCoordinate2D) {
        let loc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(loc) { [weak self] (placemarks, error) in
            guard error == nil, let placemarks = placemarks else {
                print("location coordinate is unable to reverse")
                return
            }
            
            let annotation = MKPointAnnotation()
            if placemarks.count > 0 {
                
                // Found some place with details
                let pm = placemarks[0] as CLPlacemark
                annotation.title = pm.name
                annotation.subtitle = pm.locality
                
            } else {
                
                // Placemark location is unknown
                annotation.title = C.unknownLocationTitle
            }
            
            
            annotation.coordinate = coordinate
            self?.mapView.addAnnotation(annotation)
        }
    }
    
    /**
     
     this function saves the annotation details to the core data
     
     - parameters:
        - annotation: an annotation with a valid title
     */
    func saveAnnotation(_ annotation: MKAnnotation) {
        
        guard let title = annotation.title else {
            return
        }
        
        let subtitle = annotation.subtitle
        let coordinate = annotation.coordinate
        
        // TODO: save it to DB.
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


