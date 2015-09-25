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
    @NSManaged var location: Location
    @NSManaged var id: String
    @NSManaged var user: User

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(id: String, title: String, date: NSDate, photo_description: String, user: User, location: Location?, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.id = id
        self.title = title
        self.date = date
        self.photo_description = photo_description
        self.location = location!
        self.user = user
        self.imagePath =  "\(self.title)_\(self.id)".stringByReplacingOccurrencesOfString(" ", withString: "_") + ".jpg"
    }
    
    override func prepareForDeletion() {
        bechanceClient.DocumentAccessor.imageAccessor.deleteImage(self.imagePath)
    }
    
    func saveImage(image: UIImage, imagePath: String) {
        let imageData = UIImagePNGRepresentation(image)
        _ = imageData?.writeToFile(bechanceClient.DocumentAccessor.imageAccessor.pathForIdentifier(imagePath), atomically: true)
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
