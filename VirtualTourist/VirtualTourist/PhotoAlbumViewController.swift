//
/*
PhotoAlbumViewController.swift
Created on: 6/23/18

Abstract:
 this class will show collection of images for a given latitude and longitude. As well as option to get new set of collection.
 - note: pass in latitude and longitude information.
*/

import UIKit

final class PhotoAlbumViewController: UIViewController {
    
    // MARK: Properties
    var latitude: Double!
    var longitude: Double!
    
    
    
    
    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPhotos()
    }
    
    // MARK: Convenience
    
    private func getPhotos() {
        APIManager.shared.getImages(latitude, longitude: longitude) { (photosArray, error) in
            guard error == nil else {
                print(error!)
                return
            }
            
            print(photosArray?.count ?? 0)
        }
    }
}
