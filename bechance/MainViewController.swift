//
//  MainViewController.swift
//  bechance
//
//  Created by Taiowa Waner on 8/2/15.
//  Copyright (c) 2015 Taiowa Waner. All rights reserved.
//

import UIKit
import CoreData
import Parse

class MainViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Props
    var photoButton: UIButton? = nil
    var parse_user: PFUser? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: REMOVE
        #if arch(i386) || arch(x86_64)
            let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
            NSLog("Document Path: %@", documentsPath)
        #endif
    
        if bechanceClient.sharedInstance().sharedUser == nil {
            let fetchRequest = NSFetchRequest(entityName: "User")
            fetchRequest.sortDescriptors = []
            do {
                let tmp: User = try self.sharedContext.executeFetchRequest(fetchRequest).first as! User
                bechanceClient.sharedInstance().sharedUser = tmp
            } catch {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.displayUIAlertController("No user found.", message: "Please close app and try again.", action: "Ok")
                })
            }
        }
        self.fetchedResultController.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.populate()
        
        self.photoButton = UIButton(type: UIButtonType.Custom)
        self.photoButton!.frame = CGRectMake(self.view.frame.width - self.view.frame.width / 6.0 , self.view.frame.height - self.view.frame.height / 7, 60.0, 60.0)
        self.photoButton?.backgroundColor = UIColor.redColor()
        self.photoButton?.setTitle("Photo", forState: UIControlState.Normal)
        self.photoButton?.layer.cornerRadius = self.photoButton!.frame.size.width / 2
        self.photoButton?.layer.masksToBounds = true
        self.photoButton?.layer.borderWidth = 3.0;
        self.photoButton?.layer.borderColor = UIColor.blackColor().CGColor
        self.photoButton?.addTarget(self, action: "photoButtonTapped:", forControlEvents: .TouchUpInside)
        self.view.window?.addSubview(self.photoButton!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Parse helper functions
    
    func populate() {
        bechanceClient.sharedInstance().photoArray = []
        let query = PFQuery(className: "Photo")
        query.orderByDescending("date")
        
        query.findObjectsInBackgroundWithBlock { (photos: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                for photo in photos! {
                    bechanceClient.sharedInstance().photoArray.append(photo)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.displayUIAlertController("Error", message: "Could not retrieve photos due to \(error)", action: "Ok")
                })
                print("Error with photo query: \(error)")
            }
        }
    }
    /**
    Configures a MainTableViewCell to display photos.
    - parameter cell MainTableViewCell
    - parameter photo PFObject to be used for the cell photo
    */
    func configureCell(cell: MainTableViewCell, photo: AnyObject) {
        let photo = photo as! PFObject

        (photo["image"] as! PFFile).getDataInBackgroundWithBlock { (data, error) -> Void in
            if let error = error {

                self.displayUIAlertController("Error", message: "There as an issue getting the photo data: \(error)", action: "Ok")
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    cell.cellImage?.image = UIImage(data: data!)
                })
            }
        }
        // Location
        let locationObj = photo["location"] as! PFObject
        do {
            try locationObj.fetchIfNeeded()
        } catch {
            print("Error fetching location Object \(error)")
        }
        
        cell.locationLabel?.text = (locationObj["name"] as! String)
        cell.userImage?.layer.cornerRadius = cell.userImage.frame.size.width / 2
        cell.userImage?.layer.masksToBounds = true
        let userObj = photo["user"] as! PFUser
        userObj.fetchIfNeededInBackgroundWithBlock { (object, error) -> Void in
            if let error = error {
                print("error getting user for cell \(error)")
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    cell.userLabel?.text = userObj["user_name"] as? String
                    if let image = userObj["image"] as? NSData {
                        cell.userImage?.image = UIImage(data: image)    
                    }
                })
            }
        }
        
        let dateFormat = NSDateFormatter()
        dateFormat.dateStyle = .ShortStyle
        let dateString = dateFormat.stringFromDate((photo["date"] as? NSDate)!)
        let desc = photo["description"] as! String
        cell.dateLabel?.text = dateString
        cell.descriptionLabel?.text = desc
        cell.titleLabel?.text = photo["title"] as? String
    }
    
    // MARK: - TableView Delegate Methods
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //TODO: Save photo if not from current user
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! MainTableViewCell
        configureCell(cell, photo: bechanceClient.sharedInstance().photoArray[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bechanceClient.sharedInstance().photoArray.count ?? 0
    }
    
    /**
    Performs segue to add a photo and rotates the button.
    
    - parameter sender UIButton
    */
    func photoButtonTapped(sender: UIButton!) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 2.0)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            sender.layer.addAnimation(rotateAnimation, forKey: nil)
        })
        self.performSegueWithIdentifier("PhotoSegue", sender: self)
    }
    
    // MARK: - Navigation
    /**
    Unwind segue from the FinalizeVC
    
    - parameter segue UIStoryboardSegue
    */
    @IBAction func unwindToMainView(segue: UIStoryboardSegue) {
        
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "PhotoSegue") {
            _ = segue.destinationViewController as! UINavigationController
        }
    }
    
    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
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
