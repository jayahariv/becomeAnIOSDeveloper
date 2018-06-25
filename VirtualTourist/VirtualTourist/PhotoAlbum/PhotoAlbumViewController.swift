//
/*
PhotoAlbumViewController.swift
Created on: 6/23/18

Abstract:
 this class will show collection of images for a given latitude and longitude. As well as option to get new set of collection.
 - note: pass in latitude and longitude information as well as dataController for saving the images to core data
*/

import UIKit

final class PhotoAlbumViewController: UIViewController {
    
    // MARK: Properties
    var latitude: Double!
    var longitude: Double!
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
        APIManager.shared.getImages(latitude, longitude: longitude) { [unowned self] (photosArray, error) in
            guard error == nil, let photosArray = photosArray else {
                print(error!)
                return
            }
            
            // TODO: Save to db and populate `photos` property.
            for photo in photosArray {
                
                if
                    let mediumURLString = photo[APIConstants.FlickrResponseKeys.MediumURL] as? String,
                    let mediumURL = URL(string: mediumURLString)
                {
                    let photoModel = Photo(context: self.dataController.viewContext)
                    photoModel.url = mediumURL
                }
            }
            do {
                try self.dataController.viewContext.save()
            } catch {
                print("Saving photo URLs failed \(error.localizedDescription)")
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
                                                          for: indexPath) as? PhotoCollectionViewCell,
            let url = photo.url
        else {
            fatalError("Wrong PhotoCollectionViewCell type")
        }
        
        // if already fetched.
        if let image = APIManager.shared.fetchedPhoto(url) {
            
            // set the image.
            cell.imageView.image = image
            
        } else {
           
            // TODO: fetch the image from server and display it on UI.
            APIManager.shared.fetchAndSaveImage(url) { (image, error) in
                guard error == nil, image != nil else {
                    fatalError("error")
                }
                
                DispatchQueue.main.async {
                    cell.imageView.image = image!
                }
            }
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
