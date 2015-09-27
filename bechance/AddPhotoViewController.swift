//
//  AddPhotoViewController.swift
//  bechance
//
//  Created by Taiowa Waner on 8/25/15.
//  Copyright (c) 2015 Taiowa Waner. All rights reserved.
//

import UIKit

class AddPhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var photosButton: UIButton!
    @IBOutlet weak var cogWheelBarButtonItem: UIBarButtonItem!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        
        self.cameraButton.layer.cornerRadius = 10
        self.photosButton.layer.cornerRadius = 10
        self.imageView.addObserver(self, forKeyPath: "image", options: .New, context: nil)
        self.cogWheelBarButtonItem.enabled = false
        
    }
    
    deinit {
        self.imageView.removeObserver(self, forKeyPath: "image")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - IBActions
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "image" {
            self.buttonUpdate()
            
        }
    }
    
    func buttonUpdate() {
        self.cogWheelBarButtonItem.enabled = true
        self.cogWheelBarButtonItem.image = UIImage(named: "CheckBoxFilled")
    }
    
    
    @IBAction func cogTapped(sender: AnyObject) {
        if self.imageView.image != nil {
            self.performSegueWithIdentifier("FinalSegue", sender: self)
        }
    }
    
    @IBAction func unwindToMain(sender: AnyObject) {
    }
    
    @IBAction func cameraButtonTapped(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }

    @IBAction func albumButtonTapped(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageView.image = image
        } else if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.imageView.image = image
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "FinalSegue" && self.imageView.image != nil {
            let destinationVC = segue.destinationViewController as! FinalizeViewController
                destinationVC.photo = self.imageView.image!
        }
    }
}
