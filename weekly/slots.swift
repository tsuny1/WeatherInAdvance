//
//  Slots.swift
//  weekly
//
//  Created by Will Yeung on 8/26/17.
//  Copyright © 2017 Will Yeung. All rights reserved.
//

import Foundation

class Slots {
    var beginningTimeHour: Int
    var endingTimeHour: Int
    var beginningTimeMinute: Int
    var endingTimeMinute: Int
    var location: String
    var name: String
    var selected: Bool
    var dayOfTheWeek:Int
    
    init(name: String, location: String, beginningTimeHour: Int, beginningTimeMinute:Int, endingTimeHour: Int, endingTimeMinute: Int, dayOfTheWeek:Int) {
        self.beginningTimeHour =  beginningTimeHour
        self.beginningTimeMinute =  beginningTimeMinute
        self.endingTimeHour = endingTimeHour
        self.endingTimeMinute = endingTimeMinute
        self.name = name
        self.location = location
        self.dayOfTheWeek = dayOfTheWeek
        self.selected = false
    }
}
