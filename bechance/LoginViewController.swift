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
    
    func signupUser(){
        print("SIGNUP FUNC")
    }
    
    func loginUser() {
        print("LOGIN FUNC")
    }
    
    // MARK: - IBActions
    
    @IBAction func loginSegmentTapped(sender: UISegmentedControl) {
        switch loginSegment.selectedSegmentIndex {
        case 0:
            signupLayout(true)
            self.clearTextFields()
            print("SIGNUP")
        case 1:
            signupLayout(false)
            self.clearTextFields()
            print("LOGIN")
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
