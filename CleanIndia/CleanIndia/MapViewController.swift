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

    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var addToiletButton: UIButton!
    
    private var db: Firestore!

    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        disableUIWithAuthentication()
        
        fetchToilets() 
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
    
    // MARK: Helper
    
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
    
    func fetchToilets() {
        db = Firestore.firestore()
        db.collection("toilets").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
    
}

extension MapViewController: CIAddressTypeaheadProtocol {
    func didSelectAddress(placemark: MKPlacemark) {
        print(placemark)
    }
}
