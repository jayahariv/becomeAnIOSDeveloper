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

final class PhotoAlbumViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var collectionView: UICollectionView!
    
    public var pin: Pin!

    var dataController: DataController!
    
    private var photos = [Photo]()
    
    struct C {
        static let photoCellReusableID = "photoCell"
    }
    
    
    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPhotos()
    }
    
    // MARK: Convenience
    
    private func getPhotos() {
        if let photos = pin.photos, photos.count > 0, let photosArray = Array(photos) as? [Photo] {
            self.photos = photosArray
        } else {
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
}

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    
    /// - Tag: CellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let photo = photos[indexPath.row]
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.photoCellReusableID,
                                                          for: indexPath) as? PhotoCollectionViewCell
        else {
            fatalError("Wrong PhotoCollectionViewCell type")
        }
        
        if let data = photo.image, let image = UIImage(data: data) {
            cell.imageView.image = image
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
