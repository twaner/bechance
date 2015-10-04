//
//  FinalizeViewController.swift
//  bechance
//
//  Created by Taiowa Waner on 8/25/15.
//  Copyright (c) 2015 Taiowa Waner. All rights reserved.
//

import UIKit
import CoreData
import Parse
import QuartzCore

class FinalizeViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    
    // MARK: - Var
    
    var photo: UIImage?
    var tmpLocation: [String: AnyObject]?
    var parseLocation: PFObject?
    var parsePhoto: PFObject?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleTextField.delegate = self
        self.descriptionTextView.delegate = self
        self.fetchedResultController.delegate = self
        self.locationLabel.layer.masksToBounds = true
        self.locationLabel.layer.cornerRadius = 5
        self.locationButton.layer.cornerRadius = 7
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.photo != nil {
            self.photoImageView.image = photo
        }
        if tmpLocation != nil {
            self.locationLabel.hidden = false
            self.locationLabel.text = tmpLocation!["name"] as? String
            self.locationButton.titleLabel!.text = "Update Location"
            self.parseLocationQuery((tmpLocation!["name"] as? String)!)
        }
        
        self.activityIndicator.layer.cornerRadius = self.activityIndicator.frame.size.width / 10.0
        self.activityIndicator.clipsToBounds = true
        self.displayActivityViewIndicator(false, activityIndicator: activityIndicator)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - IBAction
    
    @IBAction func AddLocationTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("SearchSegue", sender: nil)
    }
    
    @IBAction func postTapped(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.postButton.hidden = true
            self.displayActivityViewIndicator(true, activityIndicator: self.activityIndicator)
            self.view.userInteractionEnabled = false
        }
        if let location = self.parseLocation {
            self.saveParsePhoto(location)
        } else {
            self.saveParseLocation(tmpLocation!, savePhoto: true)
        }
    }
    
    // MARK: - CoreData helpers for saving
    
    func saveCoreLocation() -> Location {
        let coreLocation = Location(lat: parseLocation!["latitude"] as! NSNumber, long: parseLocation!["longitude"] as! NSNumber, subtitle: parseLocation!["state"] as! String, title: parseLocation!["city"] as! String, name: parseLocation!["name"] as! String, context: self.sharedContext)
            self.saveContext()
        return coreLocation
    }
    
    func saveCorePhoto(location: Location, photo: PFObject) -> Photo {
        let corePhoto = Photo(id: (photo.objectId)!, title: self.titleTextField.text!, date: photo["date"] as! NSDate, photo_description: self.descriptionTextView.text, user: bechanceClient.sharedInstance().sharedUser!, location: location, context: self.sharedContext)
        corePhoto.saveImage(self.photoImageView.image!, imagePath: corePhoto.imagePath)
        self.saveContext()
        return corePhoto
    }
    
    // MARK: - Parse helpers
    
    /**
    Performs a query of Parse to get  a Location PFObject
    
    - parameter name name of the location
    */
    func parseLocationQuery(name: String) {
        let query = PFQuery(className: "Location")
        query.whereKey("name", equalTo: name)
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if let _ = error {
                print("Error getting location from Parse Error: \(error)")
            } else {
                self.parseLocation = objects?.first
            }
        }
    }
    
    /**
    Saves a Location PFObject to Parse and the global parseLocation var.
    
    - parameter location dictionary containing location info.
    - parameter savePhoto Bool that determines if a photo will be saved in the completion block.
    */
    func saveParseLocation(location: [String:AnyObject], savePhoto: Bool) {
        self.parseLocation = PFObject(className: "Location")
        self.parseLocation!["latitude"] = location["lat"] as! NSNumber
        self.parseLocation!["longitude"] = location["lng"] as! NSNumber
        self.parseLocation!["name"] = location["name"] as! String
        self.parseLocation!["city"] = location["city"] as! String
        self.parseLocation!["state"] = location["state"] as! String
        self.parseLocation!["geopoints"] = PFGeoPoint(latitude:Double(location["lat"] as! NSNumber), longitude:Double(location["lng"] as! NSNumber))
        self.parseLocation!.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success && savePhoto {
                self.saveParsePhoto(self.parseLocation!)
            } else if success && !savePhoto {
                print("Location saved in Parse")
            } else {
                print("Error saving location in Parse \(error)")
                
            }
        }
    }
    
    /**
    Saves a Photo PFObject
    
    - parameter location Location PFObject
    */
    func saveParsePhoto(location: PFObject) {
        let data: NSData = UIImageJPEGRepresentation(self.photoImageView.image!, 0.8)!
        let photoFile = PFFile(data: data)
        do {
            photoFile.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if success {
                    let photo = PFObject(className: "Photo")
                    photo["title"] = self.titleTextField.text
                    photo["description"] = self.descriptionTextView.text
                    photo["user"] = PFUser.currentUser()
                    photo["date"] = NSDate()
                    photo["location"] = location
                    photo["image"] = photoFile
                    
                    photo.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                        if success {
                            let location = self.saveCoreLocation()
                            let _ = self.saveCorePhoto(location, photo: photo)
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.displayActivityViewIndicator(false, activityIndicator: self.activityIndicator)
                                self.postButton.hidden = false
                                self.view.userInteractionEnabled = true
                                self.performSegueWithIdentifier("unwindToMainViewSegue", sender: nil)
                            })
                        } else {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.displayUIAlertController("Error saving photo", message: "There was an error saving your photo \(error)", action: "Ok")
                                self.postButton.hidden = false
                                self.view.userInteractionEnabled = true
                            })
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.displayUIAlertController("Error saving photo", message: "There was an error saving your photo \(error?.localizedDescription)", action: "Ok")
                        self.postButton.hidden = false
                        self.view.userInteractionEnabled = true
                    })
                }
            })
        }
    }
    
    // MARK: - Navigation Unwind Segues
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
    }
    
    @IBAction func unwindToMainView(segue: UIStoryboardSegue) {
        
    }
    
    // MARK: - TextField
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - TextView
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == String("\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    // MARK: - CoreData Helpers
    
    lazy var fetchedResultController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "User")
        fetchRequest.sortDescriptors = []
        let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultController
        }()
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    ///
    /// Calls the saveContext() method on the sharedInstance
    ///
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }


}
