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

class ViewController: UIViewController {
let eventStore = EKEventStore()
    override func viewDidLoad() {
        super.viewDidLoad()
        initNotificationSetupCheck()
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
    
    override func applicationFinishedRestoringState() {
        checkCalendarAuthorizationStatus()
    }
    override func beginAppearanceTransition(_ isAppearing: Bool, animated: Bool) {
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
//        var titles = [String])()
        for calendar in calendars {
            
                let oneMonthAgo = NSDate(timeIntervalSinceNow: 0)
                let oneMonthAfter = NSDate(timeIntervalSinceNow: +7*24*3600)
                
                let predicate = eventStore.predicateForEvents(withStart: oneMonthAgo as Date, end: oneMonthAfter as Date, calendars: [calendar])
                
                var events = eventStore.events(matching: predicate)
                
                for event in events {
                    let date = event.startDate
                    let calendar = Calendar.current
                    let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
                    let myComponents = myCalendar.components(.weekday, from: date)
                    
                    let hour = calendar.component(.hour, from: date)
                    let minutes = calendar.component(.minute, from: date)
                    let seconds = calendar.component(.second, from: date)
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

