//
/*
AddToiletViewController.swift
Created on: 7/5/18

Abstract:
this class will manage all tasks related with adding the toilet.

*/

import UIKit
import MapKit

class AddToiletViewController: UIViewController {
    
    // MARK: Properties

    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension AddToiletViewController: CIAddressTypeaheadProtocol {
    func didSelectAddress(localSearch: MKLocalSearchCompletion) {
        print(localSearch)
    }
}
