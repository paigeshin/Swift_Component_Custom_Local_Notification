# Swift_Component_Custom_Local_Notification

```swift

//
//  NotificationPublisher.swift
//  Swift_Component_Local_Notification
//
//  Created by shin seunghyun on 2020/08/11.
//  Copyright © 2020 paige sofrtware. All rights reserved.
//


/**** Local Notification publisher Notes  ****/
/**

    - You must handle badge number in AppDelegate using this API
    - Use `notificationCenter.removeAllDeliveredNotifications()`, `notificationCenter.removeAllPendingNotificationRequests()` for UME project
    - Flow
        1. Check if user completed daily task.
        2. If user didn't complete daily task, schedule LocalNotification repetively.
        3. If user completed daily task remove all local notifications

 **/
 
/**** Implement Code Below if you want to handle application badge number ****/
/***
 
 import UIKit
 import UserNotifications

 @UIApplicationMain
 class AppDelegate: UIResponder, UIApplicationDelegate {
     
     func applicationDidBecomeActive(_ application: UIApplication) {
         application.applicationIconBadgeNumber = 0
     }
     
 }
 
 ***/

import UIKit
import UserNotifications

class LocalNotificationPublisher: NSObject {
    
    private let TAG: String = "NotificationPublisher"
    
    /** Ask Permission for local notification **/
    class func requestLocalNotificationAuthorization() {
        let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        notificationCenter.requestAuthorization(options: options) { (granted, error) in
            if let error: Error = error {
                print("LocalNotificationPublisher, static function - requestLocalNotificationAuthorization(): \(error.localizedDescription)")
                return
            }
            if granted {
                print("LocalNotificationPublisher, static function - requestLocalNotificationAuthorization(): user granted local notification authorization")
            }
        }
    }
    
    /** Foreground and Background Notification **/
    //foreground, background
    func sendNotification(title: String,
                          subTitle: String,
                          body: String,
                          badge: Int?,
                          delayInterval: TimeInterval?) {
        
        //initialize notification center
        let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()
        
        //create content
        let notificationContent: UNMutableNotificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.subtitle = subTitle
        notificationContent.body = body
        
        //create trigger
        var delayTimeTrigger: UNTimeIntervalNotificationTrigger?
        
        if let delayInterval: TimeInterval = delayInterval {
            delayTimeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: delayInterval, repeats: false)
        }
        
        //app badge number count
        if let badge: Int = badge {
            var currentBadgeCount: Int = UIApplication.shared.applicationIconBadgeNumber
            currentBadgeCount += badge
            notificationContent.badge = NSNumber(integerLiteral: currentBadgeCount)
            UIApplication.shared.applicationIconBadgeNumber = currentBadgeCount
        }
        
        //delegate
        notificationCenter.delegate = self
        
        //sound setting
        notificationContent.sound = UNNotificationSound.default //You can check multiple options
        
        //create request
        let uuid: String = UUID().uuidString
        let request: UNNotificationRequest = UNNotificationRequest(identifier: uuid, content: notificationContent, trigger: delayTimeTrigger)
        notificationCenter.add(request) { (error) in
            if let error: Error = error {
                print("\(self.TAG) - sendNotification(): \(error.localizedDescription)")
            }
        }
        
    }
    
    /** Background Notification Only **/
    //for background
    func scheduleNotification(title: String,
                              subTitle: String,
                              body: String,
                              badge: Int?,
                              delayInterval: TimeInterval,
                              repeats: Bool) {
        
        //initialize notification center
        let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()
        
        //create content
        let notificationContent: UNMutableNotificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.subtitle = subTitle
        notificationContent.body = body
        
        //create calendaer trigger
        let date: Date = Date().addingTimeInterval(delayInterval)
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .month, .second], from: date)
        let caleanderTimeTrigger: UNCalendarNotificationTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
        
        //delegate
        notificationCenter.delegate = self
        
        //create request
        let uuid: String = UUID().uuidString
        let request: UNNotificationRequest = UNNotificationRequest(identifier: uuid, content: notificationContent, trigger: caleanderTimeTrigger)
        
        //register with notification center
        notificationCenter.add(request) { (error) in
            if let error: Error = error {
                print("\(self.TAG) - scheduleNotification(): \(error.localizedDescription)")
            }
        }
        
    }
    
}

//UNUnserNotification delegate methods
extension LocalNotificationPublisher: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("The notification is about to be presented")
        //badge는 icon을 의미
        completionHandler([.badge, .sound, .alert])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.actionIdentifier
        switch identifier {
        case UNNotificationDismissActionIdentifier:
            print("The notification wasdismissed")
            completionHandler()
        case UNNotificationDefaultActionIdentifier:
            print("The user opened the app from the notification")
            completionHandler()
        default:
            print("The default case was called")
            completionHandler()
        }
    }
    
}

```