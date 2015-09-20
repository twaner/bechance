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
    
//    var venues: [String: AnyObject]?
    let locationManager = CLLocationManager()
    var lat: CLLocationDegrees?
    var long: CLLocationDegrees?
    var venue = [[String:AnyObject]]()
    var tmpLocation: [String: AnyObject] = [String: AnyObject]()
    var searchTask: NSURLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchTableView.delegate = self
        self.searchTableView.dataSource = self
        self.locationManager.delegate = self
        
        // Location - Background
        self.locationManager.requestAlwaysAuthorization()
        
        // Location - Foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if self.venue.count > 0 {
            return self.venue.count
        } else {
            return 0
        }
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
        
        let tmp: [String: AnyObject] = bechanceClient.sharedInstance().foursquareGetVenueCreator("37.785834", long: "-122.406417", location: "", providerID: "apple")
        
        searchTask = bechanceClient.sharedInstance().foursquareGetHelper(bechanceClient.Constants.VenueSearch, parameters: tmp)
            { (result, error) -> Void in
            if let error = error {
                print("ERROR calling foursquare \(error)")
            } else {
//                print(result)
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
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationValue: CLLocationCoordinate2D = manager.location!.coordinate
        
        print("locations = \(locationValue.latitude)    \(locationValue.longitude)")
        
        let location = CLLocationCoordinate2DMake(locationValue.latitude, locationValue.longitude)
        // lat & long will be used in foursquare API
        
    }
    
    // MARK: - Get venues
    
    func getVenues(searchText: String) {
        bechanceClient.sharedInstance().foursquareGetVenues("37.785834", long: "-122.406417", location: "", providerID: "apple") { (success, result, error) -> Void in
            if let error = error {
                print("ERROR calling foursquare \(error)")
            } else {
                print(result)
                if let venuesDictionary = result as? [[String: AnyObject]] {
//                        print("venue dictionary \(venuesDictionary)")
                    _ = venuesDictionary.map({self.venue.append($0) })
                    print("venue after map -> \(self.venue)")
                    self.searchTableView.reloadData()
                    }
                }
            }
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
