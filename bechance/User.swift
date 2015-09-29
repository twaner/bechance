//
//  User.swift
//
//
//  Created by Taiowa Waner on 8/1/15.
//
//

import Foundation
import CoreData

@objc(User)

class User: NSManagedObject {
    
    @NSManaged var userImage: String
    @NSManaged var username: String
    @NSManaged var firstname: String
    @NSManaged var lastname: String
    @NSManaged var user_id: String
    @NSManaged var city: String
    @NSManaged var state: String
    @NSManaged var gender: String
    @NSManaged var email: String
    @NSManaged var date: NSDate
    @NSManaged var photos: [Photo] //NSOrderedSet
//    @NSManaged var userImagePath: String
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(username: String, user_id: String, firstname: String, lastname: String, city: String, state: String, gender: String, email: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        self.username = username
        self.user_id = user_id
        self.firstname = firstname
        self.lastname = lastname
        self.city = city
        self.state = state
        self.gender = gender
        self.email = email
        self.date = NSDate()
    }
    
    var photoImage: UIImage? {
        get {
            return bechanceClient.DocumentAccessor.imageAccessor.imageWithIdentifier(userImage)
        }
        set {
            bechanceClient.DocumentAccessor.imageAccessor.storeImage(newValue, withIdentifier: userImage)
        }
    }
}
