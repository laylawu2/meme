//
//  ViewController.swift
//  meme
//
//  Created by layla wu on 11/3/20.
//  Copyright © 2020 layla wu. All rights reserved.
//

import UIKit

class CreateMemeVC: UIViewController {
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var navbar: UIToolbar!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        topTextField.text = Constants.defaultTopText
        bottomTextField.text = Constants.defaultBottomText
        selectedImage.image = nil
        shareButton.isEnabled = false
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        chooseImageFromCameraOrPhoto(source: .camera)
    }
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        chooseImageFromCameraOrPhoto(source: .photoLibrary)
    }
    
    func chooseImageFromCameraOrPhoto(source: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func shareImage(_ sender: Any) {
        let memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)

        present(activityViewController, animated: true)
        
        // Completion Handler
        activityViewController.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, arrayReturnedItems: [Any]?, error: Error?) in
            if completed {
                print("share completed")
                self.save()
                return
            } else {
                print("cancel")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextFieldStyle(forTextField: topTextField, defaultText: Constants.defaultTopText)
        setupTextFieldStyle(forTextField: bottomTextField, defaultText: Constants.defaultBottomText)

        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    override func viewWillAppear(_ animated: Bool) {
        // Disable share button if no image is selected
        if selectedImage.image == nil {
            shareButton.isEnabled = false
        }

        subscribeToKeyboardNotifications()
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }

    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }

    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func setUpTextFields() {
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            .strokeColor: UIColor.black,
            .foregroundColor: UIColor.white,
            .font: UIFont(name: Constants.fontName, size: 40)!,
            .strokeWidth: -5
        ]
        
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
    }
    
    func setupTextFieldStyle(forTextField textField: UITextField, defaultText: String = "") {
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
           .strokeColor: UIColor.black,
           .foregroundColor: UIColor.white,
           .font: UIFont(name: Constants.fontName, size: 40)!,
           .strokeWidth: -5
        ]
       
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.text = defaultText
        textField.textAlignment = .center
    }
    
    func save() {
        let memedImage = generateMemedImage()
        _ = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: selectedImage.image!, memedImage: memedImage)
    }
    
    func generateMemedImage() -> UIImage {
        // Hide toolbar and navbar
        hideToolbars(true)
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        // Show toolbar after drawing
        hideToolbars(false)
        
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return memedImage
    }
    
    func hideToolbars(_ hide: Bool) {
        toolbar.isHidden = hide
        navbar.isHidden = hide
    }
}

extension CreateMemeVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Access the image from info
        guard let image = info[UIImagePickerController.InfoKey(rawValue: Constants.imageKey)] as? UIImage else { return }
        selectedImage.contentMode = .scaleAspectFit
        selectedImage.image = image
        shareButton.isEnabled = true
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

extension CreateMemeVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
