//
//  LocationViewController.swift
//  bechance
//
//  Created by Taiowa Waner on 8/30/15.
//  Copyright (c) 2015 Taiowa Waner. All rights reserved.
//

import UIKit
import CoreLocation

class LocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate, CLLocationManagerDelegate {

    // MARK: - Outlets
    
//    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Props
    
    let locationManager = CLLocationManager()
    var lat: CLLocationDegrees?
    var long: CLLocationDegrees?
    var venue = [[String:AnyObject]]()
    var tmpLocation: [String: AnyObject] = [String: AnyObject]()
    var searchTask: NSURLSessionDataTask?
    var location: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchTableView.delegate = self
        self.searchTableView.dataSource = self
        self.locationManager.delegate = self
        
        // Location - Background
        self.locationManager.requestAlwaysAuthorization()
        
        // Location - Foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        let status = CLLocationManager.authorizationStatus()
        if CLLocationManager.locationServicesEnabled() && (status == CLAuthorizationStatus.AuthorizedAlways || status == CLAuthorizationStatus.AuthorizedWhenInUse) && status != .NotDetermined {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        } else {
            let alertController = UIAlertController(title: "Location Services Disabled", message: "Location Services have been disabled. bechance will be unbale to determine your location for your photo.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel){ (actions: UIAlertAction) in
                alertController.dismissViewControllerAnimated(true) {
                    dispatch_async(dispatch_get_main_queue()) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
            })
            alertController.addAction(UIAlertAction(title: "Open Settings", style: UIAlertActionStyle.Default){ (action: UIAlertAction) in
                if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            })
            dispatch_async(dispatch_get_main_queue()) {
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // prepopulate table
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TableView Delegate and DataSource
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell")!
        let item = self.venue[indexPath.row]
        cell.textLabel!.text = item["name"] as? String
        return cell
    }
    
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var i = self.venue[indexPath.row]
        
        if let city = (i["location"] as? NSDictionary)!.valueForKey("city") as? String {
            tmpLocation["city"] = city as String
        }
        if let state = (i["location"] as? NSDictionary)!.valueForKey("state") as? String {
            tmpLocation["state"] = state
        }
        if let lat = (i["location"] as? NSDictionary)!.valueForKey("lat") as? NSNumber {
            tmpLocation["lat"] = lat
        }
        if let lng = (i["location"] as? NSDictionary)!.valueForKey("lng") as? NSNumber {
            tmpLocation["lng"] = lng
        }
        if let task = searchTask {
            task.cancel()
        }
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.venue.count ?? 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    
    // MARK: - SearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if let task = searchTask {
            task.cancel()
        }
        
        if searchText == "" {
            venue = [[String:AnyObject]]()
            self.searchTableView.reloadData()
            return
        }
        // Check to see if location can be determined. If not message and send back.
        guard let latString = self.location, longString = self.location where location != nil else {
            dispatch_async(dispatch_get_main_queue()) {
                self.displayUIAlertController("Error", message: "Cannot determine location. Please check that Location Services are enabled.", action: "Ok")
            }
            return
        }
        
        let tmp: [String: AnyObject] = bechanceClient.sharedInstance().foursquareGetVenueCreator(latString.latitude.description, long: longString.longitude.description, location:"", providerID: "", query: searchText)
        
        searchTask = bechanceClient.sharedInstance().foursquareGetHelper(bechanceClient.Constants.VenueSearch, parameters: tmp)
            { (result, error) -> Void in
            if let error = error {
                dispatch_async(dispatch_get_main_queue()){
                    self.displayUIAlertController("Error", message: "Error getting locations from Foursquare: \(error.localizedDescription)", action: "Ok")
                }
            } else {
                if let venueDictionary = result as? NSDictionary {
                    if let venueResponse = venueDictionary.valueForKey(bechanceClient.JSONResponseKeys.Response) as? NSDictionary {
                        if let venueArray = venueResponse.valueForKey(bechanceClient.JSONResponseKeys.Venues) as? [[String: AnyObject]] {
                            self.venue = venueArray.map(){$0}
                            dispatch_async(dispatch_get_main_queue()){
                                self.searchTableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Populate table data source helper
    
    func populate() {
        
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("STATUS UPDATED")
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
                    print("Updating location")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationValue: CLLocationCoordinate2D = manager.location!.coordinate
        
        self.location = CLLocationCoordinate2DMake(locationValue.latitude, locationValue.longitude)
    }
    
    // MARK: - Navigation
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
        
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let nextVC = segue.destinationViewController as! FinalizeViewController
        
        let selectedPath: NSIndexPath = self.searchTableView.indexPathForCell(sender as! UITableViewCell)!
        
        var i = self.venue[selectedPath.row]
        print("didSelectRowAtIndex \(i)")
        
        if let city = (i["location"] as? NSDictionary)!.valueForKey("city") as? String {
            tmpLocation["city"] = city
        } else if let city = i["name"]! as? String {
            if let range = city.rangeOfString("of ", options: .BackwardsSearch, range: nil, locale: nil)?.endIndex {
                tmpLocation["city"] = city.substringFromIndex(range)
            } else {
            tmpLocation["city"] = city
            }
        }
        if let state = (i["location"] as? NSDictionary)!.valueForKey("state") as? String {
            tmpLocation["state"] = state
        }
        if let lat = (i["location"] as? NSDictionary)!.valueForKey("lat") as? NSNumber {
            tmpLocation["lat"] = lat
        }
        if let lng = (i["location"] as? NSDictionary)!.valueForKey("lng") as? NSNumber {
            tmpLocation["lng"] = lng
        if let name = i["name"]! as? String {
            tmpLocation["name"] = name
        }
        nextVC.tmpLocation = self.tmpLocation
        }
    }
}
