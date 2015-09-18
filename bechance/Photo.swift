//
//  Photo.swift
//  
//
//  Created by Taiowa Waner on 7/30/15.
//
//

import Foundation
import CoreData

@objc(Photo)
class Photo: NSManagedObject {

    @NSManaged var imagePath: String
    @NSManaged var title: String
    @NSManaged var date: NSDate
    @NSManaged var photo_description: String
    @NSManaged var tag: [Tag]
    @NSManaged var location: Location
    @NSManaged var id: String

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(id: String, title: String, date: NSDate, photo_description: String, tag: [AnyObject]?, location: Location?, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.id = id
        self.title = title
        self.date = date
        self.photo_description = photo_description
        self.tag = tag as! [Tag]!
        self.location = location!
        //TODO imagepath
//        self.imagePath =  
    }
    
    override func prepareForDeletion() {
        bechanceClient.DocumentAccessor.imageAccessor.deleteImage(self.imagePath)
    }
    
    var photoImage: UIImage? {
        get {
            return bechanceClient.DocumentAccessor.imageAccessor.imageWithIdentifier(imagePath)
        }
        set {
            bechanceClient.DocumentAccessor.imageAccessor.storeImage(newValue, withIdentifier: imagePath)
        }
    }
}
