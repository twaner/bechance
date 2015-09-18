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

}
