//
//  ImageDocumentDirectory.swift
//  Virtual Tourist
//
//  Created by Taiowa Waner on 6/25/15.
//  Copyright (c) 2015 Taiowa Waner. All rights reserved.
//

import UIKit

class ImageDocumentDirectory {
    
    private var fileManager = NSFileManager.defaultManager()
    
    func imageWithIdentifier(identifier: String?) -> UIImage? {
        if identifier == nil || identifier != "" {
            return nil
        }
        let path = pathForIdentifier(identifier!)
//        var data: NSData?
        if let data = NSData(contentsOfFile: path) {
            return UIImage(data: data)
        }
        return nil
    }
    
    /**
    Deletes an image from the document directory if the file exists at the path.
    
    - parameter identifier: filename to be turned into the path.
    */
    func deleteImage(identifier: String){
        var error: NSError?
        if fileManager.fileExistsAtPath(pathForIdentifier(identifier)) {
            do {
                try fileManager.removeItemAtPath(pathForIdentifier(identifier))
            } catch let error1 as NSError {
                error = error1
            }
        }
    }
    
    /**
    Stores an image from the document directory if the image exists or else it will remove the item from the doc directory.
    
    - parameter image: Image the to be stored.
    - parameter identifier: String that will be used to create the file path.
    */
    func storeImage(image: UIImage?, withIdentifier identifier: String) {
        let path = pathForIdentifier(identifier)
        if image == nil {
            do {
                try fileManager.removeItemAtPath(path)
            } catch _ {
            }
            return
        }
        let data = UIImagePNGRepresentation(image!)
        data!.writeToFile(path, atomically: true)
    }
    
    /**
    Creates a path from the file's name that it willbe stored at.
    
    - parameter identifier: filename to be turned into the path.
    */
    func pathForIdentifier(identifier: String) -> String {
        let docDirectoryURL: NSURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        print("pathForIdentifier REMOVE :\(docDirectoryURL)")
        let url = docDirectoryURL.URLByAppendingPathComponent((identifier as NSString).lastPathComponent)
        print("pathForIdentifier REMOVE :\(url.path!)")
        return url.path!

    }
}