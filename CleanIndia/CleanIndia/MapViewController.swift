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

class MapViewController: UIViewController {
    
    // MARK: Properties

    @IBOutlet weak var addressTextField: UITextField!

    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

extension MapViewController: CIAddressTypeaheadProtocol {
    func didSelectAddress(placemark: MKPlacemark) {
        print(placemark)
    }
}
