//
//  LoginViewController.swift
//  bechance
//
//  Created by Taiowa Waner on 7/16/15.
//  Copyright (c) 2015 Taiowa Waner. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import ParseFacebookUtilsV4

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var loginSegment: UISegmentedControl!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var password1TextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - Props
    
    let permissions = ["email", "public_profile", "user_location"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator.layer.cornerRadius = self.activityIndicator.frame.size.width / 10.0
        self.activityIndicator.clipsToBounds = true
        self.displayActivityViewIndicator(false, activityIndicator: activityIndicator)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if PFUser.currentUser() != nil {
            bechanceClient.sharedInstance().sharedParseUser = PFUser.currentUser()
            performSegueWithIdentifier("MainSegue", sender: self)
        }
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        tapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.usernameTextField.delegate = self
        self.password1TextField.delegate = self
        self.passwordTextField.delegate = self
        self.subscribeToKeyboardNotification()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.unsubscribeToKeyboardNotifications()
    }
    
    // MARK: - Helper funcs
    
    func signupLayout(signup: Bool) {
        if signup {
            password1TextField.hidden = false
        } else {
            password1TextField.hidden = true
        }
    }
    
    /**
    Checks to see if a Parse user exists. If a user exists, the user will be saved to the shared instance user.
    
    - parameter username username to verify.
    - throws error
    */
    func doesUserExist(username: String) throws -> Bool {
        let query = PFQuery(className: "User")
        query.whereKey("username", equalTo: self.usernameTextField.text!)
        do {
            let user = try query.findObjects().first
            if user != nil {
                bechanceClient.sharedInstance().sharedParseUser = user as? PFUser
                return true
            }
        } catch {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.displayUIAlertController("Username error", message: "Please try again", action: "Ok")
            })
            return false
        }
        return false
    }
    
    /**
    Signs a user up for the app using Parse
    */
    func signupUser(){
        
        do {
            if try self.doesUserExist(usernameTextField.text!) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.displayUIAlertController("Username Exits", message: "Please Select a new name", action: "Ok")
                })
                return
            }
        } catch {
            return
        }
        
        bechanceClient.sharedInstance().sharedParseUser = PFUser()
        bechanceClient.sharedInstance().sharedParseUser!.username = self.usernameTextField.text
        
        guard let username = self.usernameTextField.text where self.usernameTextField.text?.isEmpty == false else {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.displayUIAlertController("Issue with password", message: "Please re-enter username", action: "Ok")
            })
            return
        }
        bechanceClient.sharedInstance().sharedParseUser = PFUser()
        bechanceClient.sharedInstance().sharedParseUser!.username = username
        
        guard let password = self.password1TextField.text where (self.password1TextField.text == self.passwordTextField.text) && (self.passwordTextField.text?.isEmpty == false && self.password1TextField.text?.isEmpty == false) else {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.displayUIAlertController("Issue with password", message: "Please reenter passwords", action: "Ok")
            })
            return
        }
        bechanceClient.sharedInstance().sharedParseUser!.password = password
        bechanceClient.sharedInstance().sharedParseUser!["user_name"] = username
        self.performSegueWithIdentifier("NonFBSegue", sender: self)
    }
    
    /**
    Logs a user into the app using Parse
    */
    func loginUser() {
        if self.usernameTextField.text?.isEmpty == false && self.passwordTextField.text?.isEmpty == false {
            PFUser.logInWithUsernameInBackground(self.usernameTextField.text!, password: self.passwordTextField.text!) { (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    bechanceClient.sharedInstance().sharedParseUser = user
                    self.performSegueWithIdentifier("MainSegue", sender: self)
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayUIAlertController("Error Logging In", message: "An error has happened while logging in \(error?.localizedDescription)", action: "Ok")
                    }
                }
            }
        }
    }
    
    // MARK: - IBActions
    
    /**
    Determines the UI's action when the UISegmentedControl is tapped.
    - parameter sender segement that is selected
    */
    @IBAction func loginSegmentTapped(sender: UISegmentedControl) {
        switch loginSegment.selectedSegmentIndex {
        case 0:
            signupLayout(true)
            self.clearTextFields()
        case 1:
            signupLayout(false)
            self.clearTextFields()
        default:
            break
        }
    }
    
    /**
    Performs a signup/login using FB. This is shown if the user is not logged in already.
    - parameter sender button that was tapped
    */
    @IBAction func fbLoginTapped(sender: UIButton) {
        
        dispatch_async(dispatch_get_main_queue()) {
            self.displayActivityViewIndicator(true, activityIndicator: self.activityIndicator)
        }
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions, block: { (user: PFUser?, error: NSError?) -> Void in
            if let error = error {
                dispatch_async(dispatch_get_main_queue()) {
                    self.displayActivityViewIndicator(false, activityIndicator: self.activityIndicator)
                    self.displayUIAlertController("Error", message: "Error logging in with Facebook. Please Try again. \(error.localizedDescription)", action: "Ok")
                }
            } else {
                if (user != nil && PFUser.currentUser() != nil) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        bechanceClient.sharedInstance().sharedParseUser = PFUser.currentUser()
                        self.displayActivityViewIndicator(false, activityIndicator: self.activityIndicator)
                        self.performSegueWithIdentifier("LoginSegue", sender: self)
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.displayActivityViewIndicator(false, activityIndicator: self.activityIndicator)
                        self.performSegueWithIdentifier("LoginSegue", sender: self)
                    })
                }
            }
        })
    }
    
    @IBAction func SubmitTapped(sender: UIButton) {
        switch loginSegment.selectedSegmentIndex {
        case 0:
            self.signupUser()
            print("SIGNUP")
        case 1:
            self.loginUser()
            print("LOGIN")
        default:
            break
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
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if !self.password1TextField.text!.isEmpty || !self.passwordTextField.text!.isEmpty {
        }
    }
    
    // MARK: - Helper funcs
    
    func clearTextFields() {
        self.passwordTextField.text = ""
        self.password1TextField.text = ""
        self.usernameTextField.text = ""
    }
    
    // MARK: - Navigation
    
    /**
    Unwind segue for logout from UserVC.
    */
    @IBAction func logoutToMain(segue: UIStoryboardSegue) {
        
    }
}
