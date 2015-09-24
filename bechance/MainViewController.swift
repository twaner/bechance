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
        
        #if arch(i386) || arch(x86_64)
            let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
            NSLog("Document Path: %@", documentsPath)
        #endif
        
        self.populate()
        
        if bechanceClient.sharedInstance().sharedUser == nil {
            let fetchRequest = NSFetchRequest(entityName: "User")
            fetchRequest.sortDescriptors = []
            do {
                let tmp: User = try self.sharedContext.executeFetchRequest(fetchRequest).first as! User
                bechanceClient.sharedInstance().sharedUser = tmp
            } catch {
                print("NO User Found")
            }
            
        }
        
        // Delegates
        self.fetchedResultController.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
        
        self.photoButton
 = UIButton(type: UIButtonType.Custom) 
        self.photoButton!.frame = CGRectMake(self.view.frame.width - self.view.frame.width / 6.0 , self.view.frame.height - self.view.frame.height / 7, 60.0, 60.0)
        self.photoButton?.backgroundColor = UIColor.redColor()
        self.photoButton?.setTitle("Photo", forState: UIControlState.Normal)
        self.photoButton?.layer.cornerRadius = self.photoButton!.frame.size.width / 2
        self.photoButton?.layer.masksToBounds = true
        self.photoButton?.layer.borderWidth = 3.0;
        self.photoButton?.layer.borderColor = UIColor.blackColor().CGColor
        self.photoButton?.addTarget(self, action: "photoButtonTapped:", forControlEvents: .TouchUpInside)
//        self.view.addSubview(self.photoButton!) // This is above table view
        self.view.window?.addSubview(self.photoButton!) //above tab bar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Parse helper functions
    
    func populate() {

        let query = PFQuery(className: "Photo")
        
        query.findObjectsInBackgroundWithBlock { (photos: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                for photo in photos! {
                    bechanceClient.sharedInstance().photoArray.append(photo)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                }
            } else {
                print("Error with photo query: \(error)")
            }
        }
        

//        query.findObjectsInBackgroundWithBlock { (photos: [AnyObject]?, error: NSError?) -> Void in
//            if let error = error {
//                print("Error with photo query: \(error)")
//            } else {
//                if let photos = photos as? [PFObject] {
//                    for photo in photos {
//                        bechanceClient.sharedInstance().photoArray.append(photo)
//                        let desciption = photo["description"] as? String //?? ""
//                        let title = photo["title"] as? String //?? ""
//                        let dateFormat = NSDateFormatter()
//                        dateFormat.dateStyle = .ShortStyle
//                        dateFormat.timeStyle = .LongStyle
//                        let dateFromParse = photo["date"] as? NSDate
//                        let dateString = dateFormat.stringFromDate(dateFromParse)
//                        
//                        dispatch_async(dispatch_get_main_queue()) {
//                            self.tableView.reloadData()
//                        }
//                    }
//                }
//            }
//        }
        
        /**
        date = "2015-08-03 23:38:00 +0000";
        description = "Pier 2";
        image = "<PFFile: 0x7f9ac3ddfa40>";
        location = "<Location: 0x7f9ac3dc6f50, objectId: 6odJAoZGGg, localId: (null)> {\n}";
        title = "Pier 2";
        user = "<PFUser: 0x7f9ac3deae70, objectId: UfxQQs4MQo, localId: (null)> {\n}";
        */
        
    }
    /**
        Configures a MainTableViewCell to display photos.
    */
    func configureCell(cell: MainTableViewCell, photo: AnyObject) {
        let photo = photo as! PFObject

        (photo["image"] as! PFFile).getDataInBackgroundWithBlock { (data, error) -> Void in
            if let error = error {
                print("Error getting photo data to save to cell \(error)")
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    cell.cellImage?.image = UIImage(data: data!)
                })
            }
        }
        // Location
        let locationQuery = PFQuery(className: "Location")
        let userQuery = PFQuery(className: "User")
        
        let locationObj = photo["location"] as! PFObject
        do {
            try locationObj.fetchIfNeeded()
        } catch {
            print("Error fetching location Object \(error)")
        }
        
        cell.locationLabel?.text = (locationObj["name"] as! String)
        //User
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
                    //cell.userImage?.image = UIImage(data: (userObj["image"] as? NSData)!)
                })
            }
        }
        
        let dateFormat = NSDateFormatter()
        dateFormat.dateStyle = .ShortStyle
//        dateFormat.timeStyle = .ShortStyle
        let dateString = dateFormat.stringFromDate((photo["date"] as? NSDate)!)
        let desc = photo["description"] as! String
        cell.dateLabel?.text = dateString
        cell.descriptionLabel?.text = desc
        cell.titleLabel?.text = photo["title"] as? String
        // UI Updates
    }
    
    // MARK: - TableView Delegate Methods
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //TODO
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
    -param sender UIButton
    */
    func photoButtonTapped(sender: UIButton!) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 2.0)
//        rotateAnimation.duration = duration
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            sender.layer.addAnimation(rotateAnimation, forKey: nil)
        })
        
        print("Button tapped")
        self.performSegueWithIdentifier("PhotoSegue", sender: self)
//        var controller = self.storyboard?.instantiateViewControllerWithIdentifier("NavController") as! UINavigationController
//        let nextVC = controller.topViewController as! AddPhotoViewController
//        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "PhotoSegue") {
            let navController = segue.destinationViewController as! UINavigationController
//            let detailController = navController.topViewController as! AddPhotoViewController
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
