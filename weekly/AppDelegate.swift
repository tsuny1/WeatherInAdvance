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
            && result.startDayOfTheWeek == Int(storedData.dayOfTheWeek) && result.percentChanceOfRain >= 20 {
            return true
        }
        return false
    }
    
    func addNewNotifcation(result: Weather)  {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Don't forget to bring your umbrella"
        content.body = "There's gonna be " + result.shortForeCast + " at " + Helper.timeHourToString(timeHour: result.startHour) +  " today"
        content.sound = UNNotificationSound.default()
        let date = Date(timeIntervalSinceNow: 2)
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,
                                                    repeats: false)
        let identifier = "UYLLocalNotification"
        
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content, trigger: trigger)
        center.add(request, withCompletionHandler: { (error) in
        })
        
    }
    func getData() {
        Weather.forecast(){ (results:[Weather]) in
            
            let fetchRequest:NSFetchRequest<SlotEntity> = SlotEntity.fetchRequest()
            
            do {
                let fetchResults = try DatabaseController.getContext().fetch(fetchRequest)
                let center = UNUserNotificationCenter.current()
                
                center.removeAllPendingNotificationRequests()
                for oneFetchResult in fetchResults {
                    for result in results {
                        if (self.checkTimeMatch(result:result, storedData: oneFetchResult) ) {
                            self.addNewNotifcation(result:result)
                        }
                    }
                }
            }
            catch
            {
            }
        }
        
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        DatabaseController.saveContext()
    }
    
}

