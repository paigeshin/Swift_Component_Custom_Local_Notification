//
//  NotificationPublisher.swift
//  Swift_Component_Local_Notification
//
//  Created by shin seunghyun on 2020/08/11.
//  Copyright © 2020 paige sofrtware. All rights reserved.
//

import UIKit
import UserNotifications

class LocalNotificationPublisher: NSObject {
    
    private let TAG: String = "NotificationPublisher"
    private let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()
    
    func getNotificationCenter() -> UNUserNotificationCenter {
        return notificationCenter
    }
    
    class func requestLocalNotificationAuthorization() {
        
    }
    
    //foreground, background
    func sendNotification(title: String,
                          subTitle: String,
                          body: String,
                          badge: Int?,
                          delayInterval: TimeInterval?) {
        
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
        UNUserNotificationCenter.current().delegate = self
        
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
    
    //for background
    func scheduleNotification(title: String,
                              subTitle: String,
                              body: String,
                              badge: Int?,
                              delayInterval: TimeInterval) {
        
        //create content
        let notificationContent: UNMutableNotificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.subtitle = subTitle
        notificationContent.body = body
        
        //create calendaer trigger
        let date: Date = Date().addingTimeInterval(delayInterval)
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .month, .second], from: date)
        let caleanderTimeTrigger: UNCalendarNotificationTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
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
        //badge는 icon을 으미
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
