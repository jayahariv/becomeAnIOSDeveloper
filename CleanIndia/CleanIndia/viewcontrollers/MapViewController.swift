//
/*
MapViewController.swift
Created on: 7/3/18

Abstract:
this class will show the map with toilet annotations. Also includes the capabilities like
 - add new toilet.
 - show the existing toilets as list.
 - show the menu for more country wise details.
 - show my location on map.
 - search for an address.
*/

import UIKit
import MapKit
import FirebaseAuth
import Firebase

final class MapViewController: UIViewController {
    
    // MARK: Properties

    /// PRIVATE
    
    @IBOutlet weak private var addressTextField: CIAddressTypeahead!
    @IBOutlet weak private var addToiletButton: UIButton!
    @IBOutlet weak private var mapView: MKMapView!
    
    private var db: Firestore!
    private var toilets = [Toilet]()
    private let locationManager = CLLocationManager()

    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        disableUIWithAuthentication()
        
        fetchToiletsFromGoogle(Constants.Kerala.FullViewCoordinates.latitude,
                               longitude: Constants.Kerala.FullViewCoordinates.longitude,
                               delta: Constants.Kerala.fullRadius)
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: Button Actions
    
    @IBAction func onTouchUpMenu(_ sender: UIButton) {
    }
    
    @IBAction func onTouchMyLocation(_ sender: UIButton) {
        getCurrentLocation()
    }
    
    @IBAction func onTouchUpList(_ sender: UIButton) {
    }
    
    @IBAction func onTouchUpAdd(_ sender: UIButton) {
    }
}

// MARK: Private Helper methods

private extension MapViewController {
    
    /**
     authenticate and enable/disables the ` add-toilet ` button.
     */
    func disableUIWithAuthentication() {
        let email = "enterValidEmailAddress"
        let password = "enterValidPassword"
        Auth.auth().signIn(withEmail: email, password: password) { [unowned self] (result, error) in
            guard error == nil else {
                self.addToiletButton.isEnabled = false
                return
            }
        }
    }
    
    /**
     fetch all toilets from firestore and mark them as annotations in map
     */
    func fetchFirebaseToilets() {
        db = Firestore.firestore()
        db.collection(Constants.Firestore.Keys.TOILETS).getDocuments() { [unowned self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    
                    // GUARD: valid coordinate present
                    guard let coordinate: GeoPoint = data[Constants.Firestore.Keys.COORDINATE] as? GeoPoint else {
                        continue
                    }
                    
                    let location = Location(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    let geometry = Geometry(location: location)
                    let toilet = Toilet()
                    toilet.address = data[Constants.Firestore.Keys.ADDRESS] as? String
                    toilet.name = data[Constants.Firestore.Keys.NAME] as? String
                    toilet.geometry = geometry
                    
                    self.toilets.append(toilet)
                }
                
                DispatchQueue.main.async { [unowned self] in
                    self.updateMap()
                }
            }
        }
    }
    
    func fetchToiletsFromGoogle(_ latitude: Double, longitude: Double, delta: Double) {
        HttpClient.shared.getToilets(latitude: latitude, longitude: longitude, radius: delta) { [unowned self] (results: [Toilet], error: Error?) in
            
            print(results.count)
            self.toilets = results
            
            self.fetchFirebaseToilets()
        }
    }
    
    /**
     sets up the whole UI configurations in this function
        - focus the map to Kerala
     */
    func configureUI() {
        setRegion(Constants.Kerala.FullViewCoordinates.latitude,
                  longitude: Constants.Kerala.FullViewCoordinates.longitude,
                  delta: Constants.Kerala.FullViewCoordinates.delta)
    }
    
    func setRegion(_ latitude: Double, longitude: Double, delta: Double) {
        let span = MKCoordinateSpan(latitudeDelta: delta,
                                    longitudeDelta: delta)
        let center = CLLocationCoordinate2D(latitude: latitude,
                                            longitude: longitude)
        let region = MKCoordinateRegion(center: center, span: span)
        
        mapView.setRegion(region, animated: true)
    }
    
    func updateMap() {
        mapView.addAnnotations(toilets)
    }
    
    /**
     gets current location.
     */
    func getCurrentLocation() {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
}

//MARK: MapViewController -> CIAddressTypeaheadProtocol

extension MapViewController: CIAddressTypeaheadProtocol {
    func didSelectAddress(placemark: MKPlacemark) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(placemark.coordinate.latitude,
                                                           placemark.coordinate.longitude)
        annotation.title = placemark.title
        annotation.subtitle = placemark.subLocality
        
        mapView.addAnnotation(annotation)
        
        setRegion(placemark.coordinate.latitude,
                  longitude: placemark.coordinate.longitude,
                  delta: 0.02)
    }
}

// MARK: MapViewController -> MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? Toilet else { return nil }
        
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        fetchToiletsFromGoogle(mapView.region.center.latitude,
                               longitude: mapView.region.center.longitude,
                               delta: mapView.region.span.latitudeDelta)
    }
}

// MARK: AddToiletViewController -> CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        if let location = manager.location {
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            mapView.addAnnotation(annotation)
            let region = MKCoordinateRegion(center: location.coordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
            mapView.setRegion(region, animated: true)
        }
        
    }
}
