//
//  slotsAndDailyTimes.swift
//  weekly
//
//  Created by Will Yeung on 8/5/17.
//  Copyright © 2017 Will Yeung. All rights reserved.
//

import Foundation


class DailyTimes {
    var schedule = [Slots]()
    var dayOfTheWeek: Int
    
    init(dayOfTheWeek: Int) {
        self.dayOfTheWeek = dayOfTheWeek
    }
    
    func checkIfValid(intendedTime:Slots) -> Bool{
        for time in schedule {
            if (intendedTime.beginningTimeHour <= time.endingTimeHour && intendedTime.beginningTimeHour >= time.beginningTimeHour
                && intendedTime.beginningTimeMinute <= time.endingTimeMinute && intendedTime.beginningTimeMinute >= time.beginningTimeMinute) ||
                
                intendedTime.endingTimeHour <= time.endingTimeHour && intendedTime.endingTimeHour >= time.beginningTimeHour
                && intendedTime.endingTimeMinute <= time.endingTimeMinute && intendedTime.endingTimeMinute >= time.beginningTimeMinute {
              
                return false
            }
        }
        return true
    }
 
    func addTime(newTime:Slots){
        if(checkIfValid(intendedTime: newTime)){        
            schedule.append(newTime)
        }
        
    }
    
    func removeTime(index: Int){
        schedule.remove(at: index)
        
    }
}
