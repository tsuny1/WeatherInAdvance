//
//  SlotEntity+CoreDataProperties.swift
//  weekly
//
//  Created by Will Yeung on 8/11/17.
//  Copyright © 2017 Will Yeung. All rights reserved.
//

import Foundation
import CoreData


extension SlotEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SlotEntity> {
        return NSFetchRequest<SlotEntity>(entityName: "SlotEntity")
    }

    @NSManaged public var beginningTimeHour: Int16
    @NSManaged public var beginningTimeMinute: Int16
    @NSManaged public var endTimeHour: Int16
    @NSManaged public var endTimeMinute: Int16
    @NSManaged public var location: String?
    @NSManaged public var name: String?
    @NSManaged public var dayOfTheWeek: Int16
    @NSManaged public var dailyTimes: DailyTimesEntity?

}
