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
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    
    var image: UIImage?
    var memedImage: UIImage?
    
    // MARK: Bottom tool bar button values represented using this Enum
    enum BottomToolBarButton: Int { case camera = 0, album}
    
    // MARK: UI config methods
    func textAttributes() -> [String: Any] {
        return [
            NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
            NSAttributedStringKey.font.rawValue: UIFont(name: "impact", size: 40)!,
            NSAttributedStringKey.strokeWidth.rawValue: -3.0,
        ]
    }
    
    func setupTextField(_ textfield: UITextField) {
        textfield.defaultTextAttributes = textAttributes()
        textfield.textAlignment = .center
    }
    
    //Setup UI will be called only once when the view is loaded
    func setupUI() {
        setupTextField(topTextField)
        setupTextField(bottomTextField)
    }
  
    func checkSourceTypeAvailablity() {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        albumButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
    }
    
    // Update UI is called multiple times, while view loaded, and when image is picked etc.
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
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        toolBarShow(show: true)
        
        return memedImage
    }
    
    func save() {
        // hoping this will be used in Meme2.0 App
       let meme = Meme(topText: topTextField.text!,
             bottomText: bottomTextField.text!,
             originalImage: imageView.image!,
             memedImage: memedImage!)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
    // MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkSourceTypeAvailablity()
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
            cameraPicker.sourceType = .camera
        case .album:
            cameraPicker.sourceType = .photoLibrary
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
    
    @IBAction func onCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscriberKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidHide, object: nil)
    }
    
    @objc func keyboardShown(notification: Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardHide(notification: Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = 0.0
        }
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
}

