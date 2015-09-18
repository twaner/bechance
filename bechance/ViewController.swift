//
//  ViewController.swift
//  bechance
//
//  Created by Taiowa Waner on 7/16/15.
//  Copyright (c) 2015 Taiowa Waner. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let testObj = PFObject(className: "TestObject")
        testObj["foo"] = "bar"
        testObj.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            print("obj has been saved")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

