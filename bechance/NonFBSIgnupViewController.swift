//
//  NonFBSIgnupViewController.swift
//  bechance
//
//  Created by Taiowa Waner on 9/27/15.
//  Copyright © 2015 Taiowa Waner. All rights reserved.
//

import UIKit
import CoreData

class NonFBSIgnupViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var signUpImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var genderController: UISegmentedControl!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    
    
    // MARK: - Vars
    var core_user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailAddressTextField.delegate = self
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        self.cityTextField.delegate = self
        self.stateTextField.delegate = self
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        tapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)
        print("INFO \(bechanceClient.sharedInstance().sharedParseUser!.username)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeToKeyboardNotification()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeToKeyboardNotifications()
    }
    
    // MARK: - Helper methods
    
    /**
    Hides the keyboard if a TapGesture is recognized and the UITextField is the FirstResponder
    */
    
    func hideKeyboard() {
        for i in self.view.subviews {
            if i.isKindOfClass(UITextField) && i.isFirstResponder() {
                i.resignFirstResponder()
            }
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func selectImage(source: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.signUpImageView.image = image
        } else if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.signUpImageView.image = image
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - IBActions
    
    /**
    Prompts a user to select a photo from camera, if available, or library.
    
    - parameter sender UIButton as AnyObject
    */
    @IBAction func addPhotoTapped(sender: AnyObject) {
        
        let alertController = UIAlertController(title: "Add User Photo", message: "Please choose from camera or photo library", preferredStyle: .Alert)
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            alertController.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { (action: UIAlertAction) -> Void in
                self.selectImage(.Camera)
            }))
        }
        alertController.addAction(UIAlertAction(title: "Photos", style: .Default, handler: { (action: UIAlertAction) -> Void in
            self.selectImage(.PhotoLibrary)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction) -> Void in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }))
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(email)
    }
    
    func NSTextCheckingTypesFromUIDataDetectorTypes(dataDetectorType: UIDataDetectorTypes) -> NSTextCheckingType {
        var textCheckingType: NSTextCheckingType = []
        
        if dataDetectorType.contains(.Address) {
            textCheckingType.insert(.Address)
        }
        return textCheckingType
    }
    
    func cityState(str: String) -> [AnyObject] {
        let types: NSTextCheckingType = NSTextCheckingType.Address
        let detector = try? NSDataDetector(types: types.rawValue)
        var matches = [AnyObject]()
        detector?.enumerateMatchesInString(str, options: NSMatchingOptions.Anchored, range: NSMakeRange(0, (str as NSString).length)) {(result: NSTextCheckingResult?, flags: NSMatchingFlags, _) in
            matches.append(result!)
        }
        return matches
    }
    
    @IBAction func submitButtonTapped(sender: AnyObject) {
        self.view.userInteractionEnabled = false
        
        self.displayActivityViewIndicator(true, activityIndicator: self.activityIndicator)
        
        if self.signUpImageView.image != nil && self.emailAddressTextField.text?.isEmpty == false {
            
            guard let email = self.emailAddressTextField?.text where self.isValidEmail(self.emailAddressTextField.text!) else {
                self.displayUIAlertController("Invalid Email", message: "Please enter a valid email", action: "Ok")
                self.displayActivityViewIndicator(false, activityIndicator: self.activityIndicator)
                self.view.userInteractionEnabled = true
                return
            }
            bechanceClient.sharedInstance().sharedParseUser!.email = email
            bechanceClient.sharedInstance().sharedParseUser!["first_name"] = self.firstNameTextField.text!
            bechanceClient.sharedInstance().sharedParseUser!["last_name"] = self.lastNameTextField.text!
            bechanceClient.sharedInstance().sharedParseUser!["gender"] = self.genderController.selectedSegmentIndex == 0 ? "Male" : "Female"
            
            guard let city = self.cityTextField.text where self.cityTextField.text?.isEmpty == false else  {
                self.displayUIAlertController("Error", message: "Please a city", action: "Ok")
                self.displayActivityViewIndicator(false, activityIndicator: self.activityIndicator)
                self.view.userInteractionEnabled = true
                return
            }
            
            guard let state = self.stateTextField.text where self.stateTextField.text?.isEmpty == false && self.stateTextField.text?.length == 2 else  {
                self.displayUIAlertController("Error", message: "Please a 2 character state code", action: "Ok")
                self.displayActivityViewIndicator(false, activityIndicator: self.activityIndicator)
                self.view.userInteractionEnabled = true
                return
            }
            bechanceClient.sharedInstance().sharedParseUser!["state"] = state
            bechanceClient.sharedInstance().sharedParseUser!["city"] = city
            
            guard let image = self.signUpImageView.image else
            {
                self.displayUIAlertController("Photo Error", message: "No photo was available", action: "Ok")
                self.displayActivityViewIndicator(false, activityIndicator: self.activityIndicator)
                self.view.userInteractionEnabled = true
                return
            }
            
            let imageData:NSData = (data:UIImageJPEGRepresentation(image, 0.1)!)
            
            bechanceClient.sharedInstance().sharedParseUser!["image"] = imageData
            
            // Signup Parse user
            bechanceClient.sharedInstance().sharedParseUser!.signUpInBackgroundWithBlock {
                (succeeded: Bool, error: NSError?) -> Void in
                if let error = error {
                    let errorString = error.userInfo["error"] as? NSString
                    self.displayUIAlertController("Error Signing Up", message: "An error happened while singing up. Please try again. Error \(errorString!)", action: "Ok")
                    self.view.userInteractionEnabled = true
                } else {
                    bechanceClient.sharedInstance().sharedParseUser!["id"] = bechanceClient.sharedInstance().sharedParseUser!.objectId!
                    // CoreData user
                    bechanceClient.sharedInstance().sharedUser = User(username: bechanceClient.sharedInstance().sharedParseUser!.username!, user_id: bechanceClient.sharedInstance().sharedParseUser!.objectId!, firstname: bechanceClient.sharedInstance().sharedParseUser!["first_name"] as! String, lastname: bechanceClient.sharedInstance().sharedParseUser!["last_name"] as! String, city: city, state: state, gender: bechanceClient.sharedInstance().sharedParseUser!["gender"] as! String, email: email, context: self.sharedContext)
                    
                    bechanceClient.sharedInstance().sharedUser?.userImage = "user_" + bechanceClient.sharedInstance().sharedParseUser!.objectId! + ".jpg"
                    
                    bechanceClient.sharedInstance().saveImage(self.signUpImageView.image!, imagePath: (bechanceClient.sharedInstance().sharedUser?.userImage)!)
                    self.saveContext()
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.displayActivityViewIndicator(false, activityIndicator: self.activityIndicator)
                        self.view.userInteractionEnabled = true
                        self.performSegueWithIdentifier("NonFBSegue", sender: self)
                    })
                }
            }
        } else {
            dispatch_async(dispatch_get_main_queue()){
                self.displayUIAlertController("Missing Items", message: "Please be sure that you have entered your email and added a photo", action: "Ok")
                self.view.userInteractionEnabled = true
                self.displayActivityViewIndicator(false, activityIndicator: self.activityIndicator)
            }
        }
    }
    
    // MARK: - TextField
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
    }
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true;
    }
    func textFieldShouldClear(textField: UITextField) -> Bool {
        return true;
    }
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return true;
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - CoreData Helpers
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
}
