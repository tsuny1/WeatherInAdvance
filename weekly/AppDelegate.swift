//
//  AppDelegate.swift
//  weekly
//
//  Created by Will Yeung on 7/23/17.
//  Copyright © 2017 Will Yeung. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var weekDays = ["Sun","Mon","Tues","Wed","Thu","Fri","Sat"]
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let mainController = ViewController() as UIViewController
        let navigationController = UINavigationController(rootViewController: mainController)
        navigationController.navigationBar.isTranslucent = false
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        getData()
        completionHandler(.newData)
    }
    func checkTimeMatch(result: Weather, storedData: SlotEntity) -> Bool {
        
        
        if result.startHour == Int(storedData.beginningTimeHour)
            && result.startDayOfTheWeek == Int(storedData.dayOfTheWeek) {
            return true
        }
        return false
    }
    
    func addNewNotifcation(results: [Weather], fetchResults:NSFetchRequest<SlotEntity>)  {
        var count = 0
        let currentDay = Date()
        let todayDayOfTheWeek = Calendar.current.dateComponents([.weekday], from: currentDay).weekday
        let timeOfTodayNotification = getTimeOfNotifcation(day: todayDayOfTheWeek!)
        
        results.sorted (by:{ (object1, object2) -> Bool in
            let firstWeather = object1 as Weather
            let secondWeather = object2 as Weather
            let firstWeatherDifference = (firstWeather.startDayOfTheWeek - todayDayOfTheWeek!) % 7
            let secondWeatherDifference = (secondWeather.startDayOfTheWeek - todayDayOfTheWeek!) % 7
            return firstWeatherDifference < secondWeatherDifference ? true :
                firstWeather.startHour < secondWeather.startHour ? true : false; //Sorted in Ascending
            
        })
        print(results.count)
        for var index in 0 ..< results.count {
//            print("1")

            let now = Date()
            let current = results[index]
            let currentDifference = (current.startDayOfTheWeek - todayDayOfTheWeek!) % 7
            let currentIncrementedDay = Date(timeIntervalSinceNow: TimeInterval(3600*24*currentDifference))
            let currentDateOfWeek = Calendar.current.dateComponents([.weekday], from: currentIncrementedDay).weekday
            
            print("currentDateOfWeek" + String(currentDateOfWeek!))
            let currTimeOfNotification = getTimeOfNotifcation(day: currentDateOfWeek!)
            
            var triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: currentIncrementedDay)
            print("b4")
            print(triggerDate.hour)
            print(triggerDate.minute)
            triggerDate.hour = Int(currTimeOfNotification.beginningTimeHour)
            triggerDate.minute = Int(currTimeOfNotification.beginningTimeMinute)
            print("after")
            print(triggerDate.hour)
            print(triggerDate.minute)

            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,repeats: false)
            
            let identifier = String(count)
            
            let center = UNUserNotificationCenter.current()
            
            let content = UNMutableNotificationContent()
            
                      content.title = "Weather alert"
            
            content.body = "Today:" + current.shortForeCast + " at " + Helper.timeHourToString(timeHour: current.startHour) +  "\n" +
            "Rain:"
//            print("2")

            var tempStartDate = currentDateOfWeek
            var firstNotificationOfTempIndex = index
//            print("3")

            while(firstNotificationOfTempIndex < results.count){
//                print("A")

                while(firstNotificationOfTempIndex < results.count && results[firstNotificationOfTempIndex].startDayOfTheWeek == currentDateOfWeek
                     ){
//                        print("B")

                        firstNotificationOfTempIndex = firstNotificationOfTempIndex + 1
                }
                if(firstNotificationOfTempIndex < results.count) {
                content.body = content.body + weekDays[results[firstNotificationOfTempIndex].startDayOfTheWeek] + "(" +
                    String(results[firstNotificationOfTempIndex].startHour) + "), "
                //            }         //        content.sound = UNNotificationSound.default()
                }
                firstNotificationOfTempIndex = firstNotificationOfTempIndex + 1

            }
//            print("4")

            let request = UNNotificationRequest(identifier: identifier,
                                                content: content, trigger: trigger)

            center.add(request, withCompletionHandler: { (error) in
            })
            count = count + 1
            print("ASAAAAAA")

            while(results[index].startDay == currentDateOfWeek) {
                index = index + 1
            }
        }
//        print("DDDDDD")

        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
//                print(request)
            }
        })
    }
    
    func getTimeOfNotifcation(day:Int) -> SlotEntity {
        let fetchRequest:NSFetchRequest<SlotEntity> = SlotEntity.fetchRequest()
        let slotEntityClassName:String = String(describing: SlotEntity.self)
        
        let p1 = NSPredicate(format: "dayOfTheWeek == %d", 7)
        //
        //        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1])
        //        fetchRequest.predicate = predicate
        //
        
        var firstSlot: SlotEntity? = nil
        
        do {
            let searchResults = try DatabaseController.getContext().fetch(fetchRequest)
            firstSlot = searchResults[0]
            
            
            for result in searchResults {
                if(result.beginningTimeHour < (firstSlot?.beginningTimeHour)! ){
                    firstSlot = result
                }
                if(result.beginningTimeHour ==  firstSlot?.beginningTimeHour &&  result.beginningTimeMinute <= (firstSlot?.beginningTimeMinute)!){
                    firstSlot = result
                }
                
                
            }
        }
        catch {
            
        }
        
        
        return firstSlot!
        
    }
    func getData() {
        Weather.forecast(){ (results:[Weather]) in
            var arrayOfWeather:[Weather] = []
            
            let fetchRequest:NSFetchRequest<SlotEntity> = SlotEntity.fetchRequest()
            
            do {
                let fetchResults = try DatabaseController.getContext().fetch(fetchRequest)
                let center = UNUserNotificationCenter.current()
                
                center.removeAllPendingNotificationRequests()
                
                for result in results {
                    //                                        print("BB")
                    
                    for oneFetchResult in fetchResults {
                        //                                                print("AA")
                        if (self.checkTimeMatch(result:result, storedData: oneFetchResult) ) {
//                            print("CC")
                            arrayOfWeather.append(result)
                            
                            
                        }
                    }
                }
                self.addNewNotifcation(results: arrayOfWeather,fetchResults: fetchRequest)
            }
            catch
            {
            }
        }
        
    }
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        DatabaseController.saveContext()
    }
    
}

