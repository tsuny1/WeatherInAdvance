//
//  ViewController.swift
//  weekly
//
//  Created by Will Yeung on 7/23/17.
//  Copyright © 2017 Will Yeung. All rights reserved.
//

import UIKit
import EventKit
import UserNotifications
import CoreData
import CoreLocation


class ViewController: UIViewController {
    let eventStore = EKEventStore()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNotificationSetupCheck()
        checkCalendarAuthorizationStatus()
        self.view.backgroundColor = UIColor.white
        
        
        let weeklyViewButton = UIButton(frame: CGRect(x: view.frame.width / 4, y: view.frame.height / 24 * 12, width: view.frame.width / 2, height: view.frame.height / 8))
        weeklyViewButton.backgroundColor = UIColor(red: 62.0/255.0, green: 191.0/255.0, blue: 246.0/255.0, alpha: 1.0)
        weeklyViewButton.addTarget(self, action: #selector(pressButton(button:)), for: .touchUpInside)
        weeklyViewButton.setTitle("Weekly View", for: .normal)
        weeklyViewButton.layer.cornerRadius = weeklyViewButton.bounds.size.width * 0.05
        
        weeklyViewButton.titleLabel?.font = UIFont(name: "Arial", size: 20)
        
        self.view.addSubview(weeklyViewButton)
        let importButton = UIButton(frame: CGRect(x: view.frame.width / 4, y: view.frame.height / 24 * 16, width: view.frame.width / 2, height: view.frame.height / 8))
        importButton.setTitle("Import button", for: .normal)
        importButton.titleLabel?.font = UIFont(name: "Arial", size: 20)
        importButton.backgroundColor = UIColor(red: 62.0/255.0, green: 191.0/255.0, blue: 246.0/255.0, alpha: 1.0)
        
        importButton.layer.cornerRadius = importButton.bounds.size.width * 0.05
        
        UIFont.boldSystemFont(ofSize: 20)
        
        importButton.addTarget(self, action: #selector(pressImport(button:)), for: .touchUpInside)
        self.view.addSubview(weeklyViewButton)
        self.view.addSubview(importButton)
        
        
        let label = UILabel(frame: CGRect(x: view.frame.width / 4, y: view.frame.height / 5, width: 200, height: view.frame.height / 5))
        label.center = CGPoint(x: view.frame.width / 2, y: view.frame.height / 5)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Weather" + "\n" + "Notifier"
        label.font = UIFont(name: "Arial", size: 40)
        self.view.addSubview(label)
    }
    
    func initNotificationSetupCheck() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert])
        { (success, error) in
            if success {
            } else {
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        setUpNotification()
        
    }
    func setUpNotification() {
        
        let status = CLLocationManager.authorizationStatus()
        print(status)
        if status == .notDetermined || status == .denied  {
            
            // present an alert indicating location authorization required
            // and offer to take the user to Settings for the app via
            // UIApplication -openUrl: and UIApplicationOpenSettingsURLString
            
            print("LOLZ")
            
            //            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            
            
        }
        
        if(status == .authorizedWhenInUse || status == .authorizedAlways) {
            let defaults = UserDefaults.standard
            var latitude = (locationManager.location?.coordinate.latitude)!
            var longitude = (locationManager.location?.coordinate.longitude)!
            defaults.set(latitude, forKey: "latitude")
            defaults.set(longitude, forKey: "longitude")

        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func checkCalendarAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            
            requestAccessToCalendar()
        case EKAuthorizationStatus.authorized: break
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied: break
            // We need to help them give us permission
        }
    }
    func pressButton(button: UIButton) {
        let layout =  UICollectionViewLayout()
        let newViewController = weeklyViewController(collectionViewLayout:layout)
        
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    func pressImport(button: UIButton) {
        let calendars = eventStore.calendars(for: .event)
        for calendar in calendars {
            
            let oneMonthAgo = NSDate(timeIntervalSinceNow: 0)
            let oneMonthAfter = NSDate(timeIntervalSinceNow: +7*24*3600)
            
            let predicate = eventStore.predicateForEvents(withStart: oneMonthAgo as Date, end: oneMonthAfter as Date, calendars: [calendar])
            
            let events = eventStore.events(matching: predicate)
            
            for event in events {
                let calendar = Calendar.current
                let eventStartDate = event.startDate
                let eventEndDate = event.endDate
                let startHour = calendar.component(.hour, from: eventStartDate)
                let startDayOfTheWeek = (calendar.component(.weekday, from: eventStartDate) - 1) % 7
                
                let startMinute = calendar.component(.minute, from: eventStartDate)
                
                let endHour = calendar.component(.hour, from: eventEndDate)
                let endMinute = calendar.component(.minute, from: eventEndDate)
                
                do {
                    let p1 = NSPredicate(format: "beginningTimeHour <= %d", startHour)
                    let p2 = NSPredicate(format: "endTimeHour >= %d", endHour)
                    let fetchRequest:NSFetchRequest<SlotEntity> = SlotEntity.fetchRequest()
                    let slotEntityClassName:String = String(describing: SlotEntity.self)
                    
                    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1,p2])
                    fetchRequest.predicate = predicate
                    
                    let fetchResults = try DatabaseController.getContext().fetch(fetchRequest)
                    if !event.isAllDay && fetchResults.count == 0 {
                        print(startDayOfTheWeek)

                        let sampleSlotEntity = NSEntityDescription.insertNewObject(forEntityName: slotEntityClassName, into: DatabaseController.getContext()) as! SlotEntity
                        
                        sampleSlotEntity.beginningTimeHour = Int16(startHour)
                        sampleSlotEntity.beginningTimeMinute = Int16(startMinute)
                        
                        sampleSlotEntity.endTimeHour = Int16(endHour)
                        sampleSlotEntity.endTimeMinute = Int16(endMinute)
                        sampleSlotEntity.dayOfTheWeek = Int16(startDayOfTheWeek)
                        sampleSlotEntity.name = event.title
                        sampleSlotEntity.location = event.location
                        
                    }
                    
                } catch {
                    
                }
                
            }
        }
        
    }
    
    func requestAccessToCalendar() {
        
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
            
            if accessGranted == true {
                DispatchQueue.main.async(execute: {
                })
            } else {
                DispatchQueue.main.async(execute: {
                })
            }
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

