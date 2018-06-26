//
/*
PhotoCollectionViewCell.swift
Created on: 6/25/18

Abstract:
TODO: Purpose of file

*/

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    public func setImage(_ image:UIImage) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        imageView.image = image
        imageView.alpha = 1.0
    }
    
    public func loading() {
        imageView.image = nil
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        imageView.alpha = 1.0
    }
    
    public func refresh() {
        if isSelected {
            imageView.alpha = 0.50
        } else {
            imageView.alpha = 1.0
        }
    }
}
