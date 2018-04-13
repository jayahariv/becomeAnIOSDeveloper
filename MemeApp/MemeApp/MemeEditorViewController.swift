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
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    var image: UIImage?
    var memedImage: UIImage?
    var adjustViewForKeyboard: Bool = false
    
    // MARK: Bottom tool bar button values represented using this Enum
    enum BottomToolBarButton: Int { case camera = 0, album}
    
    // MARK: Meme structure created!
    struct Meme {
        var topText: String
        var bottomText: String
        var originalImage: UIImage
        var memedImage: UIImage
    }
    
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
        topTextField.defaultTextAttributes = textAttributes()
        topTextField.textAlignment = .center
        bottomTextField.defaultTextAttributes = textAttributes()
        bottomTextField.textAlignment = .center
    }
    
    func updateUI() {
        shareButton.isEnabled = imageView.image != nil
    }
    
    func populateTextFields() {
        if topTextField.text?.count == 0 {
            topTextField.text = "TOP"
        } else if bottomTextField.text?.count == 0 {
            bottomTextField.text = "BOTTOM"
        }
    }
    
    func toolBarShow(show: Bool) {
        topToolBar.isHidden = !show
        bottomToolBar.isHidden = !show
    }
    
    // MARK: utility methods
    func generateMemeImage() -> UIImage {
        
        toolBarShow(show: false)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        let result = view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        toolBarShow(show: true)
        
        print(result)
        
        return memedImage
    }
    
    func save() {
        // hoping this will be used in Meme2.0 App
       let _ = Meme(topText: topTextField.text!,
             bottomText: bottomTextField.text!,
             originalImage: imageView.image!,
             memedImage: memedImage!)
    }
    
    // MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeKeyboardNotifications()
        populateTextFields()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscriberKeyboardNotifications()
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
    @IBAction func onShare(_ sender: Any) {
        memedImage = generateMemeImage()
        let vc = UIActivityViewController.init(activityItems: [memedImage!], applicationActivities: nil)
        vc.completionWithItemsHandler = {[unowned self] (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                // remove the memedImage to free up memory, if user cancelled the activity.
                self.memedImage = nil
                return
            }
            self.save()
            self.dismiss(animated: true, completion: nil)
        };
        present(vc, animated: true, completion: nil)
    }
}

// MARK: MemeEditorViewController: UIImagePickerControllerDelegate
extension MemeEditorViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        updateUI()
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: MemeEditorViewController: UITextFieldDelegate
extension MemeEditorViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == bottomTextField {
            adjustViewForKeyboard = true
        } else {
            adjustViewForKeyboard = false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        populateTextFields()
    }
}

// MARK: MemeEditorViewController: Notification Helpers
extension MemeEditorViewController {
    func subscribeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscriberKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidHide, object: nil)
    }
    
    @objc func keyboardShown(notification: Notification) {
        if adjustViewForKeyboard {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardHide(notification: Notification) {
        if adjustViewForKeyboard {
            view.frame.origin.y = 0.0
        }
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
}

