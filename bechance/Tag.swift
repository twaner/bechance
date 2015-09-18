//
//  Tag.swift
//  
//
//  Created by Taiowa Waner on 7/30/15.
//
//

import Foundation
import CoreData

@objc(Tag)
class Tag: NSManagedObject {

    @NSManaged var tag: String
    @NSManaged var photo: Photo

}
