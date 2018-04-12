//
//  MemeEditorViewController.swift
//  MemeApp
//
//  Created by Jayahari Vavachan on 4/12/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    enum BottomToolBarButton: Int { case camera = 0, album}
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func onPressPhotos(_ sender: UIBarButtonItem) {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        switch BottomToolBarButton(rawValue: sender.tag)! {
        case .camera:
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                cameraPicker.sourceType = .camera
            } else {
                cameraPicker.sourceType = .savedPhotosAlbum
            }
        case .album:
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                cameraPicker.sourceType = .photoLibrary
            } else {
                cameraPicker.sourceType = .savedPhotosAlbum
            }
        }
        present(cameraPicker, animated: true, completion: nil)
    }
}

extension MemeEditorViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

