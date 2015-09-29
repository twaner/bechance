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
        if let _ = PFUser.currentUser()?.username {
            performSegueWithIdentifier("MainSegue", sender: self)
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
    Signs a user up for the app using Parse
    */
    func signupUser(){
        let user = PFUser()
        user.username = self.usernameTextField.text
        
        guard let username = self.usernameTextField.text where self.usernameTextField.text?.isEmpty == false else {
            self.displayUIAlertController("Issue with password", message: "Please reenter passwords", action: "Ok")
            return
        }
        user.username = username
        
        guard let password = self.password1TextField.text where self.password1TextField.text == self.passwordTextField.text && (self.passwordTextField.text?.isEmpty == false && self.password1TextField.text?.isEmpty == false) else {
            self.displayUIAlertController("Issue with password", message: "Please reenter passwords", action: "Ok")
            return
        }
        user.password = password
        
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                let errorString = error.userInfo["error"] as? NSString
                self.displayUIAlertController("Error Signing Up", message: "An error happened while singing up. Please try again. Error \(errorString)", action: "Ok")
            } else {
                self.performSegueWithIdentifier("NonFBSegue", sender: self)
            }
        }
    }
    
    /**
    Logs a user into the app using Parse
    */
    func loginUser() {
        if self.usernameTextField.text?.isEmpty == false && self.passwordTextField.text?.isEmpty == false {
            PFUser.logInWithUsernameInBackground(self.usernameTextField.text!, password: self.passwordTextField.text!) { (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    self.performSegueWithIdentifier("MainSegue", sender: self)
                }
            }
        }
    }
    
    // MARK: - IBActions
    
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
    
    ///
    /// Performs a signup/login using FB. This is shown if the user is not logged in already.
    ///
    @IBAction func fbLoginTapped(sender: UIButton) {
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.displayActivityViewIndicator(true, activityIndicator: self.activityIndicator)
        })
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions, block: { (user: PFUser?, error: NSError?) -> Void in
            
            if let error = error {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.displayUIAlertController("Error", message: "Error logging in with Facebook. Please Try again. \(error)", action: "Ok")
                })
            } else {
                if let _ = user {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.displayActivityViewIndicator(false, activityIndicator: self.activityIndicator)
                    })
                    self.performSegueWithIdentifier("LoginSegue", sender: self)
                }
            }
        })
    }
    
    @IBAction func SubmitTapped(sender: UIButton) {
        switch loginSegment.selectedSegmentIndex {
        case 0:
            self.signupUser()
        case 1:
            self.loginUser()
        default:
            break
        }
    }
    
    // MARK: - TextField
    
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
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
