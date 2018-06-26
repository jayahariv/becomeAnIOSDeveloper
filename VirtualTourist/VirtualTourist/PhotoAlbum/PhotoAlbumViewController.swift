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
    
    // private
    
    private var photos = [Photo]()
    private struct C {
        static let photoCellReusableID = "photoCell"
    }
    
    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        getPhotos()
        markInMap()
    }
    
    @IBAction func onTouchNewCollection(_ sender: UIButton) {
        pin.photos = nil
        photos = []
        collectionView.reloadData()
        fetchNewCollection()
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

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    
    /// - Tag: CellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.photoCellReusableID,
                                                          for: indexPath) as? PhotoCollectionViewCell
        else {
            fatalError("Wrong PhotoCollectionViewCell type")
        }
        if photos.count > indexPath.row, let data = photos[indexPath.row].image, let image = UIImage(data: data) {
            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.isHidden = true
            cell.imageView.image = image
        } else {
            cell.imageView.image = nil
            cell.activityIndicator.startAnimating()
            cell.activityIndicator.isHidden = false
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDataSourcePrefetching
    
    /// - Tag: Prefetching
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // Begin asynchronously fetching data for the requested index paths.
        for indexPath in indexPaths {
            let model = photos[indexPath.row]
//            asyncFetcher.fetchAsync(model.id)
        }
    }

    /// - Tag: CancelPrefetching
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        // Cancel any in-flight requests for data for the specified index paths.
        for indexPath in indexPaths {
            let model = photos[indexPath.row]
//            asyncFetcher.cancelFetch(model.id)
        }
    }
}
