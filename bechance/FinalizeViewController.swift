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

class FinalizeViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.photo != nil {
            self.photoImageView.image = photo
        }
        if tmpLocation != nil {
            self.locationLabel.text = tmpLocation!["name"] as? String
            self.parseLocationQuery((tmpLocation!["name"] as? String)!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Parse
    
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
    
    // MARK: - IBAction
    
    @IBAction func AddLocationTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("SearchSegue", sender: nil)
    }
    
    @IBAction func postTapped(sender: UIButton) {
        
        //TODO: save to parse
        
        if let location = self.parseLocation {
            self.saveParsePhoto(location)
        } else {
            self.saveParseLocation(tmpLocation!, savePhoto: true)
        }
        
        print("Photo and Location saved to Coredata")
    }
    
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
    
    func saveParseLocation(location: [String:AnyObject], savePhoto: Bool) {
        let locationParse = PFObject(className: "Location")
        locationParse["latitude"] = location["lat"] as! NSNumber
        locationParse["longitude"] = location["lng"] as! NSNumber
        locationParse["name"] = location["name"] as! String
        locationParse["city"] = location["city"] as! String
        locationParse["state"] = location["state"] as! String
        locationParse["geopoints"] = PFGeoPoint(latitude:Double(location["lat"] as! NSNumber), longitude:Double(location["lng"] as! NSNumber))
        
        locationParse.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success && savePhoto {
                print("Location saved in Parse calling saveParsePhoto")
                self.saveParsePhoto(locationParse)
            } else if success && !savePhoto {
                print("Location saved in Parse")
            } else {
                print("Error saving location in Parse \(error)")
            }
        }
        
    }
    
    func saveParsePhoto(location: PFObject) {
        let data: NSData = UIImageJPEGRepresentation(self.photoImageView.image!, 0.8)!
        let photoFile = PFFile(data: data)
        do {
            try photoFile.save()
        } catch {
            print("Error saving PhotoFile \(error)")
        }

        
        let photo = PFObject(className: "Photo")
        photo["title"] = self.titleTextField.text
        photo["description"] = self.descriptionTextView.text
        photo["user"] = PFUser.currentUser()
        photo["date"] = NSDate()
        photo["location"] = self.parseLocation
        photo["image"] = photoFile
        
        photo.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                print("Saved photo to Parse...calling saveCoreLocation()")
                let location = self.saveCoreLocation()
                let _ = self.saveCorePhoto(location, photo: photo)
            } else {
                print("Error saving photo to Parse \(error)")
            }
        }
    }
    
    // MARK: - Navigation
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
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
    
    func textViewDidBeginEditing(textView: UITextView) {
        print("DidBeginEdititng")
    }
    
    func textViewDidChange(textView: UITextView) {
        print("textViewDidChange")
    }
    
    /*
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
