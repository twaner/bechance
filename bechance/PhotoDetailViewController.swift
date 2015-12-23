//
//  PhotoDetailViewController.swift
//  bechance
//
//  Created by Taiowa Waner on 12/13/15.
//  Copyright © 2015 Taiowa Waner. All rights reserved.
//

import UIKit
import MapKit
import UberRides

class PhotoDetailViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mapKit: MKMapView!
    
    var photo: PFObject? = nil
    var image: UIImage? = nil
    var location: PFObject? = nil
    let regionRadius: CLLocationDirection = 13000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapKit.delegate = self

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        guard let imageSet = image
            else {
                return
        }
        self.imageView.image = imageSet
        self.centerMapOnLocation(location!)
        self.populateMap()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func centerMapOnLocation(location: CLLocation) {
//        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2, regionRadius * 2)
//        mapKit.setRegion(coordinateRegion, animated: true)
//    }

    func centerMapOnLocation(location: PFObject) {
        let lat = location[bechanceClient.LocationKeys.Latitude] as! Double
        let long = location[bechanceClient.LocationKeys.Longitude] as! Double
        let loc = CLLocation(latitude: lat, longitude: long)
        var coordinateRegion = MKCoordinateRegionMakeWithDistance(loc.coordinate, regionRadius * 2, regionRadius * 2)
        let loc2D = CLLocationCoordinate2D(latitude: lat, longitude: long)
        var cr = MKCoordinateRegionMake(loc2D, MKCoordinateSpanMake(0.5, 0.5))
        coordinateRegion.span.longitudeDelta = 0.05
        coordinateRegion.span.latitudeDelta = 0.05
        let adjRegion = [self.mapKit .regionThatFits(cr)]
        self.mapKit.setRegion(adjRegion[0], animated: true)
    }

    
    func populateMap() {
        guard location != nil
            else {
                // TODO Get the locaiton
                return
        }
        let lat = location![bechanceClient.LocationKeys.Latitude] as! Double
        let long = location![bechanceClient.LocationKeys.Longitude] as! Double
        let loc = CLLocation(latitude: lat, longitude: long)
        let mapLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let annotation = MKPointAnnotation()
        annotation.coordinate = mapLocation
        
        guard let state = location![bechanceClient.LocationKeys.State] as? String
            else {
                let state = ""
                return
        }
        guard let city = location![bechanceClient.LocationKeys.City] as? String
            else {
                let city  = ""
                return
        }
        guard let name = location![bechanceClient.LocationKeys.Name] as? String
            else {
                let state = ""
                return
        }
        annotation.title = name
        annotation.subtitle = "\(city), \(state)"
        self.mapKit.addAnnotation(annotation)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.mapKit.showAnnotations([annotation], animated: true)
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("DID SELECT ANNOTATION VIEW")
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        var view = MKPinAnnotationView()
        if let dequeuedView = self.mapKit.dequeueReusableAnnotationViewWithIdentifier("pin") as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            let button = RequestButton()
            view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as! UIView
            view.leftCalloutAccessoryView = button
            //view.addSubview(button)
        }
        return view
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("calloutAccessoryControlTapped")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
