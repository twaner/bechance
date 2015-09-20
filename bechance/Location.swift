//
//  Location.swift
//  
//
//  Created by Taiowa Waner on 7/30/15.
//
//

import Foundation
import CoreData

@objc(Location)
class Location: NSManagedObject {
    
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var subtitle: String
    @NSManaged var title: String
    @NSManaged var name: String
    @NSManaged var photos: NSSet
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(lat: NSNumber, long: NSNumber, subtitle: String, title: String, name: String, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        self.latitude = lat
        self.longitude = long
        self.subtitle = subtitle
        self.title = title
        self.name = name
    }
}
