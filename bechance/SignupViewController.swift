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
        
        userImage.layer.cornerRadius = self.userImage.frame.size.width / 10.0//3.0
        self.userImage.layer.borderWidth = 3.0;
        self.userImage.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.activityIndicator.layer.cornerRadius = self.activityIndicator.frame.size.width / 10.0
        self.activityIndicator.clipsToBounds = true
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.displayActivityViewIndicator(true, activityIndicator: self.activityIndicator)
        })
        
        userImage.clipsToBounds = true
        
        let parameters = ["fields": "id, name, first_name, last_name, email, location, gender"] // last_name, picture.type(large), email,picture{url}"]
        
        let graphRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: parameters)

        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if let _ = error {
                print("ERROR in request \(error)")
            } else {
                var tmp_user: [String: String] = [:]
                if let email = result.valueForKey("email") as? String {
                    self.user["email"] = email
                    tmp_user["email"] = email
                }
                if let first_name = result.valueForKey("first_name") as? String {
                    self.user["first_name"] = first_name
                    tmp_user["first_name"] = first_name
                }
                if let last_name = result.valueForKey("last_name") as? String {
                    self.user["last_name"] = last_name
                    tmp_user["last_name"] = last_name
                }
                if let user_name = result.valueForKey("name") as? String{
                    self.user["user_name"] = user_name
                    tmp_user["user_name"] = user_name
                }
                if let gender = result.valueForKey("gender") as? String {
                    self.user["gender"] = gender
                    tmp_user["gender"] = gender
                }
                
                self.user["id"] = result.valueForKey("id") as! String
                self.username.text = self.user["user_name"] as? String

                let location: [String] = ((result.valueForKey("location") as! [String: AnyObject])["name"] as! String).componentsSeparatedByString(", ") as [String]
                self.user["city"] = location[0]
                self.user["state"] = location[1]
                
                // Save in parse - no parse below!
                self.user.saveInBackground()
                let userId = PFUser.currentUser()!.objectId
                
                self.core_user = User(username: tmp_user["user_name"]!, user_id: userId!, firstname: tmp_user["first_name"]!, lastname: tmp_user["last_name"]!, city: location[0], state: location[1], gender: tmp_user["gender"]!, email: tmp_user["email"]!, context: self.sharedContext)
                self.saveContext()
                
                let id = result.valueForKey("id") as! String
                let photoUrl = "https://graph.facebook.com/\(id)/picture?type=large&return_ssl_resources=1"
                let urlRequest = NSURLRequest(URL: NSURL(string: photoUrl)!)
                
                NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: { (response, data, error) -> Void in
                    if let _ = error {
                        print("Error getting profile picture \(error)")
                    } else {
                        let image = UIImage(data: data!)
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.userImage.image = image
                        })
                        self.user["image"] = data
                        self.user.saveInBackground()
                        self.core_user?.userImage = photoUrl
                        self.saveContext()
                        bechanceClient.sharedInstance().sharedUser = self.core_user
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.displayActivityViewIndicator(false, activityIndicator: self.activityIndicator)
                    })
                })
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.username.delegate = self
//        self.subscribeToKeyboardNotification()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(animated: Bool) {
//        self.unsubscribeToKeyboardNotifications()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if self.username.text!.isEmpty {
            self.displayUIAlertController("Username error", message: "Username cannot be empty. Please add a username", action: "Ok")
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if !textField.text!.isEmpty {
            self.user["user_name"] = textField.text
            self.user.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                self.core_user?.username = textField.text!
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
