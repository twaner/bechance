//
//  bechanceConvenience.swift
//  bechance
//
//  Created by Taiowa Waner on 8/2/15.
//  Copyright (c) 2015 Taiowa Waner. All rights reserved.
//

import UIKit
import CoreData

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
     Gets a location object from parse
     
     - parameter image: UIImage to save
     */
//    func getLocation(location: PFObject) -> PFObject {
//        do {
//            try location.fetchIfNeededInBackground()
//        } catch {
//            
//        }
//        return parseLocation
//    }

    
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
        
        if !lat!.isEmpty && !long!.isEmpty {
            ll = "\(lat!),\(long!)"
        }
        if !location!.isEmpty {
            loc = location!
        }

        let dateFormater = bechanceClient.sharedInstance().dateFormatter
        dateFormater.dateFormat = "yyyyMMdd"
        let dateString = dateFormater.stringFromDate(NSDate())
        
        let parameters: [String: AnyObject] = [
            ParameterKeys.LL: ll,
            ParameterKeys.Intent: "browse",
            ParameterKeys.Location: loc,
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
        let dateFormater = bechanceClient.sharedInstance().dateFormatter
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

    
    // MARK: - User Helpers
    
    /**
    Creates a User from a PFUser object. This does not save the context
    */
    func createCoreDataUser(parseUser: PFUser, context: NSManagedObjectContext) -> User {
        let user = User(username: parseUser.username!, user_id: parseUser.objectId!, firstname: parseUser[bechanceClient.UserKeys.FirstName] as! String, lastname: parseUser[bechanceClient.UserKeys.LastName] as! String, city: parseUser[bechanceClient.UserKeys.City] as! String, state: parseUser[bechanceClient.UserKeys.State] as! String, gender: parseUser[bechanceClient.UserKeys.Gender] as! String, email: parseUser.email!, context: context)
        return user
    }
    
    /**
    Creates a Parse and a dictionary of keys from a user from a FB Graph Request
    - parameter result The result of the Graph Request
    - parameter user PFUser to update and save.
    - parameter username username for User
    
    -returns a tuple containing a PFUser and a dictionary of values for creating a CoreData user.s
    */
    func createUserFromGraphRequest(user: PFUser, result: AnyObject, username: String) -> (user: PFUser, userDict: [String: String]){
        
        var tmpUser: [String: String] = [:]
        if let email = result.valueForKey(bechanceClient.UserKeys.Email) as? String {
            user[bechanceClient.UserKeys.Email] = email
            tmpUser[bechanceClient.UserKeys.Email] = email
        }
        if let first_name = result.valueForKey(bechanceClient.UserKeys.FirstName) as? String {
            user[bechanceClient.UserKeys.FirstName] = first_name
            tmpUser[bechanceClient.UserKeys.FirstName] = first_name
        }
        if let last_name = result.valueForKey(bechanceClient.UserKeys.LastName) as? String {
            user[bechanceClient.UserKeys.LastName] = last_name
            tmpUser[bechanceClient.UserKeys.LastName] = last_name
        }
        if let user_name = result.valueForKey(bechanceClient.UserKeys.Name) as? String{
            user[bechanceClient.UserKeys.UserNameUnder] = user_name
            tmpUser[bechanceClient.UserKeys.UserNameUnder] = user_name
        }
        if let gender = result.valueForKey(bechanceClient.UserKeys.Gender) as? String {
            user[bechanceClient.UserKeys.Gender] = gender
            tmpUser[bechanceClient.UserKeys.Gender] = gender
        }
        
        user[bechanceClient.UserKeys.ID] = result.valueForKey(bechanceClient.UserKeys.ID) as! String
        user[bechanceClient.UserKeys.UserName] = username
        user.username = username
        let location: [String] = ((result.valueForKey(bechanceClient.JSONResponseKeys.Location) as! [String: AnyObject])[bechanceClient.JSONResponseKeys.Name] as! String).componentsSeparatedByString(",")
        tmpUser[bechanceClient.JSONResponseKeys.City] = location[0]
        tmpUser[bechanceClient.JSONResponseKeys.State] = location[1]
        let id = result.valueForKey(bechanceClient.UserKeys.ID) as! String
        tmpUser[bechanceClient.UserKeys.PhotoURL] = "https://graph.facebook.com/\(id)/picture?type=large&return_ssl_resources=1"
        return (user, tmpUser)
    }
    
    /**
    Helper for using a dataTaskWithRequest to get a photo from FB
    */
    func facebookImageTaskHelper(userDict: [String: String], location: [String], photoUrl: String, imageView: UIImageView, urlRequest: NSURLRequest, parseUser: PFUser, var coreUser: User, context: NSManagedObjectContext) {
        let task = session.dataTaskWithRequest(urlRequest) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if let _ = error {
            } else {
                let image = UIImage(data: data!)
                dispatch_async(dispatch_get_main_queue()) {
                    imageView.image = image
                }
                parseUser["image"] = data
                parseUser.saveInBackground()
                coreUser.userImage = bechanceClient.subtituteKeyInMethod(bechanceClient.Constants.FacebookPhotoURL, key: "id", value: parseUser.objectId!)!
                let userId = PFUser.currentUser()!.objectId
                
                coreUser = User(username: userDict["user_name"]!, user_id: userId!, firstname: userDict["first_name"]!, lastname: userDict["last_name"]!, city: location[0], state: location[1], gender: userDict["gender"]!, email: userDict["email"]!, context: context)
                
                bechanceClient.sharedInstance().saveImage(image!, imagePath: photoUrl)
                bechanceClient.sharedInstance().sharedParseUser = parseUser
                bechanceClient.sharedInstance().sharedUser = coreUser

            }
        }
    task.resume()
    }

}