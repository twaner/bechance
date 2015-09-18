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
    
    
    func taskForCreatingImage(filePath: String, completionHandler: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionTask {
        _ = NSURL(string: filePath)
        
        let request = NSURLRequest(URL: NSURL(string: filePath)!)
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
    
//    func taskForCall(resource: String, parameters: [String: AnyObject], completionHander: CompletionHander) -> NSURLSessionDataTask {
//        var params = parameters
//        var resc = resource
//        
////        let urlString = 
//        
//    }
    
    // MARK: - Foursquare Get
    
    func foursquareGetVenueCreator(lat: String?, long: String?, location: String?, providerID: String?) -> [String: AnyObject] {
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
            ParameterKeys.ProviderId: provID,
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
//                        println("Venue Array:  \(venueArray)")
                        completionHander(success: true, result: venueArray, error: nil)
                    }
                }
            }
        }
    }
}