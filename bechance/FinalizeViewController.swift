//
//  FinalizeViewController.swift
//  bechance
//
//  Created by Taiowa Waner on 8/25/15.
//  Copyright (c) 2015 Taiowa Waner. All rights reserved.
//

import UIKit

class FinalizeViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    // MARK: - Outlets
    
    var photo: UIImage?
    var tmpLocation: [String: AnyObject]?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.photo != nil {
            self.photoImageView.image = photo
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBAction
    
    @IBAction func searchTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("SearchSegue", sender: nil)
    }
    
    


    // MARK: - Navigation
    
    @IBAction func prepareFOrUnwind(segue: UIStoryboardSegue) {
        
    }
    
    /*
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
