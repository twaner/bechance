//
//  ShareCard.swift
//  bechance
//
//  Created by Taiowa Waner on 12/6/15.
//  Copyright © 2015 Taiowa Waner. All rights reserved.
//

import UIKit

class ShareCard: NSObject, UIActivityItemSource {
    
    // props
    var user: String = ""
    var title: String = ""
    var location: String = ""
//    var image: UIImage? = nil
    
    func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject {
        print("placeholder")
        return user
    }
    
    func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        print("Placeholder itemForActivity")
        
        if activityType == UIActivityTypePostToFacebook {
            return "\(user) took this photo on @bechanceApp \(title) at \(location)"
        } else if activityType == UIActivityTypePostToTwitter {
            return "\(user) took this photo on @bechanceApp \(title) at \(location)"
        } else {
            return "\(user) took this photo on bechance app \(title) at \(location)"
        }
    }
}
