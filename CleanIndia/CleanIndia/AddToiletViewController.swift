//
/*
AddToiletViewController.swift
Created on: 7/5/18

Abstract:
this class will manage all tasks related with adding the toilet.

*/

import UIKit
import MapKit

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
    
    private var rate: UInt8 = 5
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        dismiss(animated: true, completion: nil)
    }
}

extension AddToiletViewController: CIAddressTypeaheadProtocol {
    func didSelectAddress(placemark: MKPlacemark) {
        print(placemark)
    }
}
