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
    @IBOutlet weak var bottomBannerHeight: NSLayoutConstraint!
    
    private var pins = [Pin]()
    private var editButton: UIButton!
    
    
    /// constants for this class
    
    private struct C {
        static let annotationViewReusableID: String = "annotationViewReusableID"
        static let unknownLocationTitle: String = "Unknown location"
        static let bottomBannerHeight: CGFloat = 65.0
        static let D: Double = 80 * 1.1
        static let R: Double = 6371009 // Earth readius in meters
    }

    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        refreshUI()
        
        loadPins()
    }
    
    // MARK: Actions
    
    @objc private func onEdit() {
        isEditing = !isEditing
        refreshUI()
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
        
        addEditButton()
        
        // add long press gesture recognizer.
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:)))
        longPressGesture.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    /**
     adds an edit button in the left navigation bar
     */
    private func addEditButton() {
        editButton = UIButton(type: .custom)
        editButton.setTitle("Edit", for: .normal)
        editButton.setTitle("Done", for: .selected)
        editButton.setTitleColor(.blue, for: .normal)
        editButton.setTitleColor(.blue, for: .selected)
        editButton.addTarget(self, action: #selector(onEdit), for: .touchUpInside)
        editButton.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editButton)
    }
    
    /**
        with respect to the `isEditing` property, configure the UI.
     */
    private func refreshUI() {
        if isEditing {
            bottomBannerHeight.constant = C.bottomBannerHeight
            editButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        } else {
            bottomBannerHeight.constant = 0.0
            editButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        }
        editButton.isSelected = isEditing
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
    
    /**
     loads all pins and annotate in map. It uses the property pins to annotate.
     */
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
    
    /**
     creates an annotation for the given arguments.
     - parameters:
        - title: annotation title
        - subtitle: (optional) annotation subtitle
        - coordinate: annotation coordinate
     */
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if isEditing {
            view.removeFromSuperview()
            
            // remove from db
            let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
            let pointOfInterest: CLLocationCoordinate2D = (view.annotation?.coordinate)!

            fetchRequest.predicate = predicateForDeltaLocation(pointOfInterest)
            
            do {
                let result = try dataController.viewContext.fetch(fetchRequest)
                if let result = result.first {
                    dataController.viewContext.delete(result)
                    try dataController.viewContext.save()
                }
                
            } catch {
                print(error)
            }
        }
    }
    
    /**
     creates a predicate for fetching a Pin for the given Coordinate.
     
     - parameters:
        - pointOfInterest: coordinate for which the predicate will be created
     - returns: predicate which will return Pins which are present in the interested area
     */
    private func predicateForDeltaLocation(_ pointOfInterest: CLLocationCoordinate2D) -> NSPredicate {
        let meanLatitidue = pointOfInterest.latitude * Double.pi / 180;
        let deltaLatitude = C.D / C.R * 180 / Double.pi;
        let deltaLongitude = C.D / (C.R * cos(meanLatitidue)) * 180 / Double.pi;
        
        let minLatitude = pointOfInterest.latitude - deltaLatitude;
        let maxLatitude = pointOfInterest.latitude + deltaLatitude;
        let minLongitude = pointOfInterest.longitude - deltaLongitude;
        let maxLongitude = pointOfInterest.longitude + deltaLongitude;
        
        return NSPredicate(format: "(longitude >= \(minLongitude)) AND (longitude <= \(maxLongitude))" +
            "AND (lattitude >= \(minLatitude)) AND (lattitude <= \(maxLatitude))")
    }
}


