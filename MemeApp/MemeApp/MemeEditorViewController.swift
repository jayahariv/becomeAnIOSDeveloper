//
//  MemeEditorViewController.swift
//  MemeApp
//
//  Created by Jayahari Vavachan on 4/12/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UINavigationControllerDelegate {
    
    // MARK: properties
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topLabel: UITextField!
    @IBOutlet weak var bottomLabel: UITextField!
    
    enum BottomToolBarButton: Int { case camera = 0, album}
    var image: UIImage?
    
    // MARK: UI config methods
    func textAttributes() -> [String: Any] {
        return [
            NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
            NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedStringKey.strokeWidth.rawValue: -1.0,
        ]
    }
    
    func setupUI() {
        topLabel.text = "TOP"
        topLabel.defaultTextAttributes = textAttributes()
        topLabel.textAlignment = .center
        
        bottomLabel.text = "BOTTOM"
        bottomLabel.defaultTextAttributes = textAttributes()
        bottomLabel.textAlignment = .center
    }
    
    // MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: Button Actions
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

// MARK: MemeEditorViewController: UIImagePickerControllerDelegate
extension MemeEditorViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

