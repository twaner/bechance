//
//  TaskCancellingCollectionViewCell.swift
//  bechance
//
//  Created by Taiowa Waner on 9/20/15.
//  Copyright © 2015 Taiowa Waner. All rights reserved.
//

import UIKit

import UIKit

class TaskCancellingCollectionViewCell: UICollectionViewCell {
    var imageName: String = ""
    
    var taskToCancelIfCellIsReused: NSURLSessionTask? {
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
}
