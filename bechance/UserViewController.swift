//
//  UserViewController.swift
//  bechance
//
//  Created by Taiowa Waner on 8/9/15.
//  Copyright (c) 2015 Taiowa Waner. All rights reserved.
//

import UIKit
import CoreData
import Parse

class UserViewController: UIViewController, NSFetchedResultsControllerDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var firstnameLabel: UILabel!
    @IBOutlet weak var lastnameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var userDateLabel: UILabel!
    @IBOutlet weak var photosLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    
    // MARK: - Props
    
    var user: PFUser?
    var coreUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        user = PFUser.currentUser()
        let fetchRequest = NSFetchRequest(entityName: "User")
        fetchRequest.sortDescriptors = []
        let tmp = (try? self.sharedContext.executeFetchRequest(fetchRequest))?.first as! User
        
        // Delegates
        self.fetchedResultController.delegate = self
        self.coreUser = tmp
        
        // Update appearance
        self.usernameLabel.text = coreUser?.username
        self.firstnameLabel.text = coreUser?.firstname
        self.lastnameLabel.text = coreUser?.lastname
        self.locationLabel.text = "\(coreUser!.city), \(coreUser!.state)"
        let dateFormat = NSDateFormatter()
        dateFormat.dateStyle = .ShortStyle
        let dateString = dateFormat.stringFromDate((coreUser!.date as? NSDate)!)
        self.userDateLabel.text = dateString
        let imagePath = coreUser?.userImage as String?
        let task = bechanceClient.sharedInstance().taskForCreatingImage(imagePath!, completionHandler: { (imageData, error) -> Void in
            if let error = error {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.displayUIAlertController("Error getting photo", message: "Photo download error: \(error.localizedDescription)", action: "Ok")
                })
            } else {
                if let data = imageData {
                    let image = UIImage(data: data)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.userImageView.image = image
                    })
                }
            }
        })
//        self.userImageView.image = coreUser.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showItemSegue") {
            let navController = segue.destinationViewController as! UINavigationController
            let detailController = navController.topViewController as! AddPhotoViewController
        }
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
