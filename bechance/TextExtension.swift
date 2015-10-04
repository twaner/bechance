//
//  TextExtension.swift
//  bechance
//
//  Created by Taiowa Waner on 7/16/15.
//  Copyright (c) 2015 Taiowa Waner. All rights reserved.
//

import UIKit

extension UIViewController {
    
    var keyboardShowing: Bool {
        get {
            return self.keyboardShowing
        }
        set {
            if newValue {
                self.keyboardShowing = newValue
            }
        }
    }
    
    // MARK: - UIKeyboard methods
    
    /**
    Adds an observer to the UIKeyboardWillShowNotification and UIKeyboardWillHideNotification.
    Set subscription in the viewWillAppear() method: self.subscribeToKeyboardNotification()
    */
    func subscribeToKeyboardNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardFrameWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /**
    Removes an observer to the UIKeyboardWillShowNotification and UIKeyboardWillHideNotification.
    Set subscription in the viewWillDisappear() method: self.subscribeToKeyboardNotification()
    */
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /**
    Helper methods for subscriptions
    */
    
    /**
    Shows the keyboard if the view's bottom is at 0.0 else returns
    */
    func keyboardWillShow(notification: NSNotification) {
        if self.view.frame.origin.y < 0.0 {
            return
        }
        self.view.frame.origin.y -= getKeyboardHeight(notification)
    }
    /**
    */
    func keyboardFrameWillHide(notification: NSNotification) {
        self.view.frame.origin.y += getKeyboardHeight(notification)
    }
    /**
    */
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    // MARK: - UI Helpers
    
    ///
    /// Displays or hides an activity indicator.
    ///
    /// - parameter on: Turns activity indicator on or off.
    func displayActivityViewIndicator(on: Bool, activityIndicator: UIActivityIndicatorView) {
        if on {
            activityIndicator.startAnimating()
            activityIndicator.alpha = 1.0
        } else {
            activityIndicator.alpha = 0.0
            activityIndicator.stopAnimating()
        }
    }
    
    ///
    /// Displays an UIAlertController
    ///
    /// - parameter title: of Alert
    /// - parameter message: message of alert
    /// - parameter action: title for the action button.
    func displayUIAlertController(title:String, message:String, action: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: action, style: .Default, handler: { action in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

/**
Provides a length property to a String

- returns number of characters in a string
*/
extension String {
    var length : Int {
        return self.characters.count
    }
}

