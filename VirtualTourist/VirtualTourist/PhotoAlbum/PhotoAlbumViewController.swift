//
/*
PhotoAlbumViewController.swift
Created on: 6/23/18

Abstract:
 this class will show collection of images for a given latitude and longitude. As well as option to get new set of collection.
 - note: pass in latitude and longitude information as well as dataController for saving the images to core data
 
 getPhotos -> list of image URLs
 from ImageURLs -> get all images
 
*/

import UIKit
import CoreData
import MapKit

final class PhotoAlbumViewController: UIViewController {
    
    // MARK: Properties
    public var pin: Pin!
    public var dataController: DataController!
    
    // IBOutlet
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    // private
    
    private var photos = [Photo]()
    private struct C {
        static let photoCellReusableID = "photoCell"
    }
    private var selectedIndexPath: IndexPath? = nil
    
    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        getPhotos()
        markInMap()
    }
    
    @IBAction func onTouchNewCollection(_ sender: UIButton) {
        if let indexPath = selectedIndexPath {
            do {
                let photo = photos[indexPath.row]
                dataController.viewContext.delete(photo)
                try dataController.viewContext.save()
                photos.remove(at: indexPath.row)
                collectionView.deleteItems(at: [indexPath])
                selectedIndexPath = nil
                
            } catch {
                print("Error removing image")
            }
            
        } else {
            pin.photos = nil
            photos = []
            collectionView.reloadData()
            fetchNewCollection()
        }
    }
    
    // MARK: Convenience
    
    private func markInMap() {
        
        let center = CLLocationCoordinate2D(latitude: pin.lattitude, longitude: pin.longitude)
        let region = MKCoordinateRegion(center: center,
                                        span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0))
        
        let annotation = MKPointAnnotation()
        annotation.title = pin.title
        annotation.subtitle = pin.subtitle
        annotation.coordinate = center
        
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: true)
    }
    
    private func getPhotos() {
        if let photos = pin.photos, photos.count > 0, let photosArray = Array(photos) as? [Photo] {
            self.photos = photosArray
        } else {
            fetchNewCollection()
        }
    }
    
    private func fetchNewCollection() {
        APIManager.shared.getImages(pin) { [unowned self] (photos, error) in
            guard error == nil, let photos = photos else {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                
                self.photos = photos
                self.collectionView.reloadData()
            }
        }
    }
}

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count == 0 ? 10 : photos.count
    }
    
    
    /// - Tag: CellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.photoCellReusableID,
                                                          for: indexPath) as? PhotoCollectionViewCell
        else {
            fatalError("Wrong PhotoCollectionViewCell type")
        }
        if
            photos.count > indexPath.row,
            let data = photos[indexPath.row].image,
            let image = UIImage(data: data) {
            
            cell.setImage(image)
        
        } else {
            
            cell.loading()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        cell.refresh()
        
        selectedIndexPath = indexPath
        newCollectionButton.titleLabel?.text = "Remove Image"
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        cell.refresh()
    }
}
