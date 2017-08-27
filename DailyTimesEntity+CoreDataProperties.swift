//
//  DailyTimesEntity+CoreDataProperties.swift
//  weekly
//
//  Created by Will Yeung on 8/11/17.
//  Copyright © 2017 Will Yeung. All rights reserved.
//

import Foundation
import CoreData


extension DailyTimesEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DailyTimesEntity> {
        return NSFetchRequest<DailyTimesEntity>(entityName: "DailyTimesEntity")
    }

    @NSManaged public var dayOfTheWeek: Int16
    @NSManaged public var slots: NSSet?

}

// MARK: Generated accessors for slots
extension DailyTimesEntity {

    @objc(addSlotsObject:)
    @NSManaged public func addToSlots(_ value: SlotEntity)

    @objc(removeSlotsObject:)
    @NSManaged public func removeFromSlots(_ value: SlotEntity)

    @objc(addSlots:)
    @NSManaged public func addToSlots(_ values: NSSet)

    @objc(removeSlots:)
    @NSManaged public func removeFromSlots(_ values: NSSet)

}
