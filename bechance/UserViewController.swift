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

class UserViewController: UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    // MARK: - Outlets
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var firstnameLabel: UILabel!
    @IBOutlet weak var lastnameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var userDateLabel: UILabel!
    @IBOutlet weak var photosLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    // MARK: - Props
    
//    var coreUser: User?
    var photos: [Photo]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photoCollectionView.dataSource = self
        self.photoCollectionView.delegate = self

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        do {
            try self.fetchedResultController.performFetch()
        } catch let error as NSError {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.displayUIAlertController("Error", message: "There was an error getting user data: \(error.localizedDescription)", action: "Ok")
            })
            abort()
        }
        self.photos = self.fetchedResultController.fetchedObjects as? [Photo]
        if self.photos?.count > 0 {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.photoCollectionView.reloadData()
            })
        }
        
        // Delegates
        self.fetchedResultController.delegate = self
        
        // Update appearance
        self.updateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateUI() {
        // Update appearance
        self.usernameLabel.text = bechanceClient.sharedInstance().sharedUser?.username
        self.firstnameLabel.text = bechanceClient.sharedInstance().sharedUser?.firstname
        self.lastnameLabel.text = bechanceClient.sharedInstance().sharedUser?.lastname
        self.locationLabel.text = "\(bechanceClient.sharedInstance().sharedUser!.city), \(bechanceClient.sharedInstance().sharedUser!.state)"
        let dateFormat = bechanceClient.sharedInstance().dateFormatter
        self.photosLabel.text = self.photos!.count > 0 ? "\(self.photos!.count)" : "0"
        dateFormat.dateStyle = .ShortStyle
        self.userDateLabel.text = dateFormat.stringFromDate(bechanceClient.sharedInstance().sharedUser!.date)
        bechanceClient.sharedInstance().taskForGettingImageFromDocuments((bechanceClient.sharedInstance().sharedUser?.userImage)!) { (imageData, error) -> Void in
            if let error = error {
                dispatch_async(dispatch_get_main_queue()) {
                    self.displayUIAlertController("Error getting photo", message: "Photo download error: \(error.localizedDescription)", action: "Ok")
                }
            } else {
                if let data = imageData {
                    let image = UIImage(data: data)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.userImageView.image = image
                    }
                }
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showItemSegue") {
            let navController = segue.destinationViewController as! UINavigationController
            _ = navController.topViewController as! AddPhotoViewController
        }
    }
    
    // MARK: - CollectionView Delegate and Helpers
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        cell.activityIndicator.startAnimating()
        let photo = fetchedResultController.objectAtIndexPath(indexPath) as! Photo
        configureCell(cell, photo: photo)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos?.count ?? 0
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultController.sections?.count ?? 0
    }
    
    /*
    Configures the appearance of a collection view cell.
    parameter - cell PhotoCollectionViewCell
    parameter - photo Photo object
    */
    func configureCell(cell: PhotoCollectionViewCell, photo: Photo) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            cell.activityIndicator.startAnimating()
        })

        var photoImage = UIImage(named: "Blank52")
        cell.cellImage.image = nil
        if photo.imagePath == "" || photo.imagePath.isEmpty {
            photoImage = UIImage(named: "Blank52")
        } else {
            let task = bechanceClient.sharedInstance().taskForGettingImageFromDocuments(photo.imagePath) { (imageData, error) -> Void in
                if let error = error {
                    print("Local photo get error : \(error.localizedDescription)")
                } else {
                    if let data = imageData {
                        let image = UIImage(data: data)
                        photo.photoImage = image
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            cell.activityIndicator.hidesWhenStopped = true
                            cell.activityIndicator.stopAnimating()
                            cell.cellImage.image = image
                        })
                    }
                }
            }
            cell.taskToCancelIfCellIsReused = task
        }
        cell.cellImage.image = photoImage
    }
    
    
    
    @IBAction func logoutTapped(sender: UIButton) {
        PFUser.logOut()
        bechanceClient.sharedInstance().sharedParseUser = PFUser.currentUser()
    }
    
    /**
    Logs a user out and unwinds to the signin screen.
    - parameter segue to perform
    */
    @IBAction func logoutToMain(segue: UIStoryboardSegue) {
        
    }
    
    // MARK: - CoreData Helpers
    
    lazy var fetchedResultController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "user == %@", bechanceClient.sharedInstance().sharedUser!)
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
