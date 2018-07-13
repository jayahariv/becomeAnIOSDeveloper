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

    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        disableUIWithAuthentication()
        
        fetchToilets()
        
        configureUI()
    }
    
    // MARK: Button Actions
    
    @IBAction func onTouchUpMenu(_ sender: UIButton) {
    }
    
    @IBAction func onTouchMyLocation(_ sender: UIButton) {
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
    func fetchToilets() {
        db = Firestore.firestore()
        db.collection(Constants.Firestore.Keys.TOILETS).getDocuments() { [unowned self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                var annotations = [MKPointAnnotation]()
                for document in querySnapshot!.documents {
                    let data = document.data()
                    
                    // GUARD: valid coordinate present
                    guard let coordinate: GeoPoint = data[Constants.Firestore.Keys.COORDINATE] as? GeoPoint else {
                        continue
                    }
                    
                    // GUARD: valid name is present
                    guard let title = data[Constants.Firestore.Keys.NAME] as? String else {
                        continue
                    }
                    
                    // GUARD: valid address is present
                    guard let subtitle = data[Constants.Firestore.Keys.ADDRESS] as? String else {
                        continue
                    }
                    
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
                    annotation.title = title
                    annotation.subtitle = subtitle
                    
                    annotations.append(annotation)
                }
                
                self.mapView.addAnnotations(annotations)
            }
        }
    }
    
    /**
     sets up the whole UI configurations in this function
        - focus the map to India
     - todo:
        - check if we can gray out the outside area.
        - auto zoom to the user location when he enabled the location.
     */
    func configureUI() {
        let span = MKCoordinateSpan(latitudeDelta: Constants.India.FullViewCoordinates.delta,
                                    longitudeDelta: Constants.India.FullViewCoordinates.delta)
        let center = CLLocationCoordinate2D(latitude: Constants.India.FullViewCoordinates.latitude,
                                            longitude: Constants.India.FullViewCoordinates.longitude)
        let region = MKCoordinateRegion(center: center, span: span)
        
        mapView.setRegion(region, animated: true)
    }
}

//MARK: MapViewController -> CIAddressTypeaheadProtocol

extension MapViewController: CIAddressTypeaheadProtocol {
    func didSelectAddress(placemark: MKPlacemark) {
        print(placemark)
    }
}
