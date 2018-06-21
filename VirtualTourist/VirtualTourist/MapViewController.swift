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
import CoreData

/**
 the main view controller, users can
 - add a pin.
 - remove a pin.
 - go to photo album. 
 */

final class MapViewController: UIViewController {
    
    // MARK: Properties
    
    public var dataController: DataController!
    
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
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        do {
            let result = try dataController.viewContext.fetch(fetchRequest)
            pins = result
            refreshMap()
        } catch {
            print(error)
        }
    }
    
    private func refreshMap() {
        var annotations = [MKAnnotation]()
        for pin in pins {
            if let title = pin.title {
                let coordinate = CLLocationCoordinate2D(latitude: pin.lattitude, longitude: pin.longitude)
                annotations.append(makeAnnotation(title, subtitle: pin.subtitle, coordinate: coordinate))
            }
        }
        self.mapView.addAnnotations(annotations)
    }
    
    /**
     
     add annotation to the map & verify first whether the coordinates is valid.
     
     - parameters:
        - coordinate: coordinates for the annotation
     */
    func addAnnotation(_ coordinate: CLLocationCoordinate2D) {
        let loc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(loc) { [unowned self] (placemarks, error) in
            guard error == nil, let placemarks = placemarks else {
                print("location coordinate is unable to reverse")
                return
            }
            
            let annotation: MKAnnotation!
            
            if placemarks.count > 0, let name = placemarks[0].name {
                // Found some place with details
                annotation = self.makeAnnotation(name, subtitle: placemarks[0].locality, coordinate: coordinate)
                
            } else {
                
                // Placemark location is unknown
                annotation = self.makeAnnotation(C.unknownLocationTitle, subtitle: nil, coordinate: coordinate)
            }
            
            self.saveAnnotation(annotation)
            self.mapView.addAnnotation(annotation)
        }
    }
    
    func makeAnnotation(_ title: String, subtitle: String?, coordinate: CLLocationCoordinate2D) -> MKAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = coordinate
        return annotation
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
        
        // save to db
        let pin = Pin(context: dataController.viewContext)
        pin.lattitude = annotation.coordinate.latitude
        pin.longitude = annotation.coordinate.longitude
        pin.title = title
        pin.subtitle = annotation.subtitle ?? ""
        do {
            try dataController.viewContext.save()
        } catch {
            print("Saving failed")
        }
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
            view.rightCalloutAccessoryView = UIButton(type: .custom)
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        // TODO: go to photo album view controller.
    }
}


