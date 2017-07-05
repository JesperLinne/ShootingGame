//
//  Entity+CoreDataProperties.swift
//  ShootingCircules
//
//  Created by Jesper Linne on 2016-09-23.
//  Copyright © 2016 Jesper Linné. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Entity {

    @NSManaged var highScore: NSNumber?

}
