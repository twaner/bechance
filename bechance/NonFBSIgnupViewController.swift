//
//  NonFBSIgnupViewController.swift
//  bechance
//
//  Created by Taiowa Waner on 9/27/15.
//  Copyright © 2015 Taiowa Waner. All rights reserved.
//

import UIKit
import CoreData

class NonFBSIgnupViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
    var user: PFUser = PFUser.currentUser()!
    var core_user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        presentViewController(alertController, animated: true, completion: nil)
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
        if self.signUpImageView.image != nil && self.emailAddressTextField.text?.isEmpty == false {
            
            // Save to Parse & CoreData
            guard let email = self.emailAddressTextField?.text where self.isValidEmail(self.emailAddressTextField.text!) else {
                self.displayUIAlertController("Invalid Email", message: "Please enter a valid email", action: "Ok")
                return
            }
            user.email = email
            user["first_name"] = self.firstNameTextField.text!
            user["last_name"] = self.lastNameTextField.text!
            user["gender"] = self.genderController.selectedSegmentIndex == 0 ? "Male" : "Female"
            
            guard let city = self.cityTextField.text where self.cityTextField.text?.isEmpty == false else  {
                return
            }
            
            guard let state = self.stateTextField.text where self.stateTextField.text?.isEmpty == false && self.stateTextField.text?.length == 2 else  {
                return
            }
            user["state"] = state
            user["city"] = city
            
            
            
            //TODO: Save to Coredata
            bechanceClient.sharedInstance().sharedUser = User(username: user["username"] as! String, user_id: user.objectId!, firstname: user["first_name"] as! String, lastname: user["last_name"] as! String, city: city, state: state, gender: user["gender"] as! String, email: email, context: self.sharedContext)
            self.saveContext()
            
        } else {
            self.displayUIAlertController("Missing Items", message: "Please be sure that you have entered your email and added a photo", action: "Ok")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    // MARK: - CoreData Helpers
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
}
