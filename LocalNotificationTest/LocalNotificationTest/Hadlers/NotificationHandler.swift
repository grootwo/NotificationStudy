//
//  NotificationHandler.swift
//  LocalNotificationTest
//
//  Created by Groo on 6/17/24.
//

import Foundation
import UserNotifications

class NotificationHandler {
    func askPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("permission: access granted")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func sendNotification(date: Date, type: String, timeInterval: Double = 5, title: String, body: String) {
        var trigger: UNNotificationTrigger?
        if type == "calendar" {
            let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        } else if type == "timeInterval" {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        } else if type == "repeat" {
            let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        }
        
        let contet = UNMutableNotificationContent()
        contet.title = title
        contet.body = body
        contet.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "LongPop.mp3"))
        
        if type == "action" {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            let content = UNMutableNotificationContent()
            content.title = "Weekly Staff Meeting"
            content.body = "Every Tuesday at 2pm"
            content.userInfo = ["MEETING_ID" : "meetingID",
                                "USER_ID" : "userID" ]
            content.categoryIdentifier = "MEETING_INVITATION"
        }
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: contet, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
           didReceive response: UNNotificationResponse,
           withCompletionHandler completionHandler:
             @escaping () -> Void) {
           
       // Get the meeting ID from the original notification.
       let userInfo = response.notification.request.content.userInfo
       let meetingID = userInfo["MEETING_ID"] as! String
       let userID = userInfo["USER_ID"] as! String
            
       // Perform the task associated with the action.
       switch response.actionIdentifier {
       case "ACCEPT_ACTION":
          print("action: acccept")
          break
            
       case "DECLINE_ACTION":
          print("action: decline")
          break
            
       // Handle other actions...
       default:
          break
       }
        
       // Always call the completion handler when done.
       completionHandler()
    }
}
