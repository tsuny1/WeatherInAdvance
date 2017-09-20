
import UIKit
import Foundation

class Helper{
    
    
    
    static func setSectionToTrue(array: [[Bool]], section:Int, startingI:Int, endingI:Int, offset: Int)  -> [[Bool]]{
        var a = array
        let sI = startingI <= endingI ? startingI : endingI
        let eI = startingI <= endingI ? endingI : startingI
        for index in sI...eI{
            a[section][index - offset] = true
        }
        return a
    }
    
    static func timeHourToString(timeHour:Int) -> String {
        if timeHour < 12 {
            return "\(timeHour) A.M"
        }
        if timeHour > 12 {
            
            let timeInPM = timeHour - 12
            return "\(timeInPM) P.M"
        }
        return "\(timeHour) P.M"
        
    }
    static func getDayOfWeek(date: Date)->Int? {
        let myCalendar = NSCalendar.current
        let myComponents = myCalendar.dateComponents([.day,.month,.year,.weekday], from: date)
        let weekDay = myComponents.weekday
        return weekDay
    }
    
    static func deletePreviousSection(array: [[Bool]], section:Int, startingI:Int, endingI:Int, offset: Int) -> [[Bool]]{
        var a = array
    let sI = startingI <= endingI ? startingI : endingI
    let eI = startingI <= endingI ? endingI : startingI
    for index in sI...eI{
    a[section][index - offset] = false
    }
        return a
    
    }
    
    static func convertTimeToIndex (numberOfSlots:Int, startingHour: Int, numberOfIntervalsInHour: Int, timeHour: Int, timeMinute:Int, offset:Int) -> Int {
        
        let differenceInHour = timeHour - startingHour
        let index = offset + (differenceInHour * numberOfIntervalsInHour) + (timeMinute / 15)
        return index
    }
    
    static func convertIndexToTimeMinute(numberOfSlots:Int, startingHour: Int, numberOfIntervalsInHour: Int, index: Int, offset:Int) -> Int{
        let minute = (index  - offset ) % 4 * 15
              return minute
    }
    static func convertIndexToTimeHour(numberOfSlots:Int, startingHour: Int, numberOfIntervalsInHour: Int, index: Int, offset:Int) -> Int{
        let hour = startingHour + (index - offset) / 4
            return hour
    }
    

}
