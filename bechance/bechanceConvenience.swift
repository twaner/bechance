//
//  bechanceConvenience.swift
//  bechance
//
//  Created by Taiowa Waner on 8/2/15.
//  Copyright (c) 2015 Taiowa Waner. All rights reserved.
//

import Foundation
import UIKit

extension bechanceClient {
    
    /**
    Saves an image to the document directory using a name as the file path.
    
    - parameter image: UIImage to save
    - parameter imagePath: Path for the image.
    */
    func saveImage(image: UIImage, imagePath: String) {
        let imageData = UIImagePNGRepresentation(image)
        imageData?.writeToFile(bechanceClient.DocumentAccessor.imageAccessor.pathForIdentifier(imagePath), atomically: true)
    }
    
    /**
    Gets an image from the documents directory using an NSURLSessionTask
    
    - parameter filePath: file path for image
    - parameter completionHandler: The completion handler to call when the load request is complete. This handler is executed on the delegate queue.
    */
    func taskForGettingImageFromDocuments(filePath: String, completionHandler: (imageData: NSData?, error: NSError?) -> Void) -> NSURLSessionTask {
        let docDirectoryURL: NSURL = bechanceClient.DocumentAccessor.imageAccessor.documentDirectory
        let url = docDirectoryURL.URLByAppendingPathComponent((filePath as NSString).lastPathComponent)
        let request = NSURLRequest(URL: url)
        let task = session.dataTaskWithRequest(request) {
            (data, response, downloadError) in
            if let error = downloadError {
                bechanceClient.errorForData(data, response: response, error: error)
            } else {
                completionHandler(imageData: data!, error: nil)
            }
        }
        task.resume()
        return task
    }
    
    /**
    Gets an image from a hyperlink using an NSURLSessionTask
    
    - parameter filePath: file path for image
    - parameter completionHandler: The completion handler to call when the load request is complete. This handler is executed on the delegate queue.
    */
    func taskForCreatingImage(filePath: String, completionHandler: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionTask {

        let url = NSURL(string: filePath)
        let request = NSURLRequest(URL: url!)
        let task = session.dataTaskWithRequest(request) {
            (data, response, downloadError) in
            if let error = downloadError {
                _ = bechanceClient.errorForData(data, response: response, error: error)
            } else {
                completionHandler(imageData: data, error: nil)
            }
        }
        task.resume()
        return task
    }
    
    // MARK: - Foursquare Get
    
    func foursquareGetVenueCreator(lat: String?, long: String?, location: String?, providerID: String?, query: String?) -> [String: AnyObject] {
        var ll = ""
        var loc = ""
        var provID = ""
        
        if !lat!.isEmpty && !long!.isEmpty {
            ll = "\(lat!),\(long!)"
        }
        if !location!.isEmpty {
            loc = location!
        }
        if !providerID!.isEmpty {
            provID = providerID!
        }
        let dateFormater = NSDateFormatter()
        dateFormater.dateFormat = "yyyyMMdd"
        let dateString = dateFormater.stringFromDate(NSDate())
        
        let parameters: [String: AnyObject] = [
            ParameterKeys.LL: ll,
            ParameterKeys.Intent: "browse",
            ParameterKeys.Location: loc,
//            ParameterKeys.ProviderId: provID,
            ParameterKeys.Query: query!,
            ParameterKeys.ClientSecret: FourSquare.ClientSecret,
            ParameterKeys.ClientID: FourSquare.ClientID,
            ParameterKeys.Version: dateString
        ]
        return parameters
    }
    
    func foursquareGetVenues(lat: String?, long: String?, location: String?, providerID: String?, completionHander: (success:Bool, result: AnyObject?, error: NSError?) -> Void) {
        var ll = ""
        var loc = ""
        var provID = ""
        
        if !lat!.isEmpty && !long!.isEmpty {
            ll = "\(lat!),\(long!)"
        }
        if !location!.isEmpty {
            loc = location!
        }
        if !providerID!.isEmpty {
            provID = providerID!
        }
        let dateFormater = NSDateFormatter()
        dateFormater.dateFormat = "yyyyMMdd"
        let dateString = dateFormater.stringFromDate(NSDate())
        
//        var versionDate = 
        
        let parameters: [String: AnyObject] = [
            ParameterKeys.LL: ll,
            ParameterKeys.Intent: "browse",
            ParameterKeys.Location: loc,
            ParameterKeys.ProviderId: provID,
            ParameterKeys.ClientSecret: FourSquare.ClientSecret,
            ParameterKeys.ClientID: FourSquare.ClientID,
            ParameterKeys.Version: dateString
        ]
        
        foursquareGetHelper(Constants.VenueSearch, parameters: parameters) { (result, error) -> Void in
            if let error = error {
                completionHander(success: false, result: nil, error: error)
            } else {
                if let venueDictionary = result!.valueForKey(JSONResponseKeys.Response) as? NSDictionary {
                    if let venueArray = venueDictionary.valueForKey(JSONResponseKeys.Venues) as? [[String: AnyObject]] {
                        completionHander(success: true, result: venueArray, error: nil)
                    }
                }
            }
        }
    }
}