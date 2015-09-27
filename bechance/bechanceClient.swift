//
//  bechanceClient.swift
//  bechance
//
//  Created by Taiowa Waner on 7/16/15.
//  Copyright (c) 2015 Taiowa Waner. All rights reserved.
//

import Foundation
import Parse

class bechanceClient {
    
    // MARK: - Props
    var session: NSURLSession
    var photoArray: [PFObject] = []
    var sharedUser: User?
    let dateFormatter = NSDateFormatter()
    
    typealias CompletionHander = (result: AnyObject!, error: NSError?) -> Void
    
    init() {
        self.session = NSURLSession.sharedSession()
    }
    
    // MARK: - All purpose task method for data
    
    func taskForResource(resource: String, parameters: [String : AnyObject], completionHandler: CompletionHander) -> NSURLSessionDataTask {
        
        var mutableParameters = parameters
        _ = resource
        
        // Add in the API Key
        mutableParameters["api_key"] = ""//Constants.ApiKey
        
        let urlString = ""
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        print(url)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                let newError = bechanceClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                print("Step 3 - taskForResource's completionHandler is invoked.")
                bechanceClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }
        
        task.resume()
        
        return task
    }

    // MARK: - Foursquare Helpers
    
    func foursquareGetHelper(method: String, parameters: [String: AnyObject], CompletionHander: (result: AnyObject?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let urlString = bechanceClient.Constants.BaseFoursquareURL + bechanceClient.Constants.VenueSearch + bechanceClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)
        let request = NSURLRequest(URL: url!)
        
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) in
            if let error = error {
                let newError = bechanceClient.errorForData(data, response: response, error: error)
                print("foursquare error -> \(newError)")
            } else {
                bechanceClient.parseJSONWithCompletionHandler(data!, completionHandler: CompletionHander)
            }
        }
        task.resume()
        return task
    }
    
    // MARK: - Helpers
    
    /**
    Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    /** Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error 
    
    */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        guard let dataClean = data where data != nil else {
            return error as NSError
        }
        
        var error: NSError?
        do {
            let parsedResult = try NSJSONSerialization.JSONObjectWithData(dataClean, options: .AllowFragments) as? [String: AnyObject]
            if let errorMessage = parsedResult![bechanceClient.JSONResponseKeys.Meta] as? String {
                
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                error =  NSError(domain: "TMDB Error", code: 1, userInfo: userInfo)
            }
        } catch let error as NSError {
            return error
        }
        return error!

    }
    
    /**
    Helper: Given raw JSON, return a usable Foundation object
    */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    /** Helper function: Given a dictionary of parameters, convert to a string for a url 
    - parameter escapedParameters parameters in dictionary format.
    */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    class func sharedInstance() -> bechanceClient {
        struct Singleton {
            static var sharedInstance = bechanceClient()
        }
        return Singleton.sharedInstance
    }
    
    // MARK: - Document Directory Helper
    
    struct DocumentAccessor {
        static let imageAccessor = ImageDocumentDirectory()
    }
    
    // MARK: - Shared Image Cache
    
//    struct Caches {
//        static let imageCache = ImageCache()
//    }
}