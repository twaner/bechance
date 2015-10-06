//
//  SignupViewController.swift
//  bechance
//
//  Created by Taiowa Waner on 7/16/15.
//  Copyright (c) 2015 Taiowa Waner. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import CoreData

/**
Class for signing up a Parse user using Facebook.
*/
class SignupViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    var user: PFUser = PFUser.currentUser()!
    var core_user: User?
    
    // MARK: - Lifecycle
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setupUI()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.displayActivityViewIndicator(true, activityIndicator: self.activityIndicator)
        })
        
        let parameters = bechanceClient.Constants.FacebookParameters //["fields": "id, name, first_name, last_name, email, location, gender"]
        
        let graphRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: parameters)

        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if let error = error {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.displayUIAlertController("Ok", message: "Error conntecting to FB \(error.localizedDescription)", action: "Ok")
                })
            } else {
                var tmp_user: [String: String] = [:]
                if let email = result.valueForKey(bechanceClient.UserKeys.Email) as? String {
                    self.user[bechanceClient.UserKeys.Email] = email
                    tmp_user[bechanceClient.UserKeys.Email] = email
                }
                if let first_name = result.valueForKey(bechanceClient.UserKeys.FirstName) as? String {
                    self.user[bechanceClient.UserKeys.FirstName] = first_name
                    tmp_user[bechanceClient.UserKeys.FirstName] = first_name
                }
                if let last_name = result.valueForKey(bechanceClient.UserKeys.LastName) as? String {
                    self.user[bechanceClient.UserKeys.LastName] = last_name
                    tmp_user[bechanceClient.UserKeys.LastName] = last_name
                }
                if let user_name = result.valueForKey(bechanceClient.UserKeys.Name) as? String{
                    self.user[bechanceClient.UserKeys.UserNameUnder] = user_name
                    tmp_user[bechanceClient.UserKeys.UserNameUnder] = user_name
                }
                if let gender = result.valueForKey(bechanceClient.UserKeys.Gender) as? String {
                    self.user[bechanceClient.UserKeys.Gender] = gender
                    tmp_user[bechanceClient.UserKeys.Gender] = gender
                }
                
                self.user[bechanceClient.UserKeys.ID] = result.valueForKey(bechanceClient.UserKeys.ID) as! String
                self.user[bechanceClient.UserKeys.UserName] = self.username.text!
                self.user.username = self.username.text!
                
                let location: [String] = ((result.valueForKey(bechanceClient.JSONResponseKeys.Location) as! [String: AnyObject])[bechanceClient.JSONResponseKeys.Name] as! String).componentsSeparatedByString(",")

                let id = result.valueForKey(bechanceClient.UserKeys.ID) as! String
                let photoUrl = "https://graph.facebook.com/\(id)/picture?type=large&return_ssl_resources=1"
                let urlRequest = NSURLRequest(URL: NSURL(string: photoUrl)!)
                
                // Get Data
                let dataTask = bechanceClient.sharedInstance().session.dataTaskWithRequest(urlRequest) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                    if let error = error {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.displayUIAlertController("Error", message: "An error occured while getting information from FB. Please try again \(error.localizedDescription)", action: "Ok")
                        })
                    } else {
                        let image = UIImage(data: data!)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.userImage.image = image
                        }
                        self.user[bechanceClient.UserKeys.Image] = data
                        self.user.saveInBackground()
                        self.core_user?.userImage = photoUrl
                        let userId = PFUser.currentUser()!.objectId
                        
                        self.core_user = User(username: tmp_user[bechanceClient.UserKeys.UserNameUnder]!, user_id: userId!, firstname: tmp_user[bechanceClient.UserKeys.FirstName]!, lastname: tmp_user[bechanceClient.UserKeys.LastName]!, city: location[0], state: location[1], gender: tmp_user[bechanceClient.UserKeys.Gender]!, email: tmp_user[bechanceClient.UserKeys.Email]!, context: self.sharedContext)
                        self.saveContext()
                        
                        bechanceClient.sharedInstance().saveImage(image!, imagePath: photoUrl)
                        bechanceClient.sharedInstance().sharedParseUser = self.user
                        bechanceClient.sharedInstance().sharedUser = self.core_user
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.displayActivityViewIndicator(false, activityIndicator: self.activityIndicator)
                        }
                    }
                }
                dataTask.resume()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.username.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func textFieldDidEndEditing(textField: UITextField) {
        if self.username.text!.isEmpty {
            self.displayUIAlertController("Username error", message: "Username cannot be empty. Please add a username", action: "Ok")
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if !textField.text!.isEmpty {
            
            bechanceClient.sharedInstance().sharedParseUser?.username = textField.text!
            bechanceClient.sharedInstance().sharedParseUser?[bechanceClient.UserKeys.UserNameUnder] = textField.text!
            self.user.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                bechanceClient.sharedInstance().sharedUser!.username = textField.text!
                self.saveContext()
            })
        }
        return true
    }
    
    @IBAction func submitTapped(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.displayActivityViewIndicator(true, activityIndicator: self.activityIndicator)
        })
        if !self.username.text!.isEmpty {
            self.performSegueWithIdentifier("MainSegue", sender: self)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.displayActivityViewIndicator(false, activityIndicator: self.activityIndicator)
            })
        } else {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.displayActivityViewIndicator(false, activityIndicator: self.activityIndicator)
                self.displayUIAlertController("Username error", message: "Username cannot be empty. Please add a username", action: "Ok")
            })
        }
    }

    // MARK: - UI Helpers
    /**
    Configures the UI appearance
    */
    func setupUI() {
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 10.0//3.0
        self.userImage.layer.borderWidth = 3.0;
        self.userImage.layer.borderColor = UIColor.whiteColor().CGColor
        self.userImage.clipsToBounds = true
        self.activityIndicator.layer.cornerRadius = self.activityIndicator.frame.size.width / 10.0
        self.activityIndicator.clipsToBounds = true
    }

    
    
    // MARK: - CoreData Helpers
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
}
