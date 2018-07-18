//
/*
AddToiletViewController.swift
Created on: 7/5/18

Abstract:
this class will manage all tasks related with adding the toilet.

*/

import UIKit
import MapKit
import Firebase

final class AddToiletViewController: UIViewController {
    
    // MARK: Properties

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var reviewDescription: UILabel!
    @IBOutlet weak var name: UITextField!
    
    /// ratings buttons
    @IBOutlet weak var rate1: UIButton!
    @IBOutlet weak var rate2: UIButton!
    @IBOutlet weak var rate3: UIButton!
    @IBOutlet weak var rate4: UIButton!
    @IBOutlet weak var rate5: UIButton!
    
    // private vars
    private var rate: UInt8 = 5
    private let db = (UIApplication.shared.delegate as! AppDelegate).db
    private var placemark: MKPlacemark?
    private let locationManager = CLLocationManager()

    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    // MARK: Button Actions
    
    @IBAction func onTouchReviewStar(_ sender: UIButton) {
        
        // todo: code refactor
        
        switch sender.tag {
        case 1:
            rate1.isSelected = true
            rate2.isSelected = false
            rate3.isSelected = false
            rate4.isSelected = false
            rate5.isSelected = false
        case 2:
            rate1.isSelected = true
            rate2.isSelected = true
            rate3.isSelected = false
            rate4.isSelected = false
            rate5.isSelected = false
        case 3:
            rate1.isSelected = true
            rate2.isSelected = true
            rate3.isSelected = true
            rate4.isSelected = false
            rate5.isSelected = false
        case 4:
            rate1.isSelected = true
            rate2.isSelected = true
            rate3.isSelected = true
            rate4.isSelected = true
            rate5.isSelected = false
        case 5:
            rate1.isSelected = true
            rate2.isSelected = true
            rate3.isSelected = true
            rate4.isSelected = true
            rate5.isSelected = true
        default:
            print("Review Selection Invalid")
        }
        rate = UInt8(sender.tag)
    }
    
    @IBAction func onCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onAdd(_ sender: UIBarButtonItem) {
        guard let name = self.name.text else {
            return
        }
        
        guard let coordinate = placemark?.coordinate else {
            return
        }
        
        guard let address = placemark?.title else {
            return
        }
        
        onSave(name,
               rating: rate,
               address: address,
               coordinate: GeoPoint(latitude: coordinate.latitude,
                                    longitude: coordinate.longitude)
        ) {[unowned self] in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: Helper functions
    
    func onSave(_ name: String,
                rating: UInt8,
                address: String,
                coordinate: GeoPoint,
                completion: @escaping () -> Void) {
        
        var ref: DocumentReference? = nil
        ref = db?.collection(Constants.Firestore.Keys.TOILETS).addDocument(data: [
            Constants.Firestore.Keys.NAME: name,
            Constants.Firestore.Keys.RATING: rating,
            Constants.Firestore.Keys.ADDRESS: address,
            Constants.Firestore.Keys.COORDINATE: coordinate
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                completion()
            }
        }
    }
    
    @IBAction func onMyLocation(_ sender: UIButton) {
        getCurrentLocation()
    }
}

private extension AddToiletViewController {
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
    
    /**
     sets up the whole UI configurations in this function
     - focus the map to Kerala
     - todo:
     - check if we can gray out the outside area.
     - auto zoom to the user location when he enabled the location.
     */
    func configureUI() {
        setRegion(Constants.Kerala.FullViewCoordinates.latitude,
                  longitude: Constants.Kerala.FullViewCoordinates.longitude,
                  delta: Constants.Kerala.FullViewCoordinates.delta)
    }
    
    /**
     sets the region on the map
     */
    func setRegion(_ latitude: Double, longitude: Double, delta: Double) {
        let span = MKCoordinateSpan(latitudeDelta: delta,
                                    longitudeDelta: delta)
        let center = CLLocationCoordinate2D(latitude: latitude,
                                            longitude: longitude)
        let region = MKCoordinateRegion(center: center, span: span)
        
        mapView.setRegion(region, animated: true)
    }
    
}

extension AddToiletViewController: CIAddressTypeaheadProtocol {
    func didSelectAddress(placemark: MKPlacemark) {
        self.placemark = placemark
    }
}

extension AddToiletViewController: CLLocationManagerDelegate {
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
