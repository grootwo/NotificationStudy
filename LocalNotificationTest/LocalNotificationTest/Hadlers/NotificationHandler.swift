//
//  NotificationHandler.swift
//  LocalNotificationTest
//
//  Created by Groo on 6/17/24.
//

import Foundation
import UserNotifications

class NotificationHandler: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
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
        setCategories()
        
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
    
    func setCategories() {
        print("set: categories")
        // Define the custom actions.
        let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION",
                                                title: "Accept",
                                                options: [])
        let declineAction = UNNotificationAction(identifier: "DECLINE_ACTION",
                                                 title: "Decline",
                                                 options: [])
        // Define the notification type
        let meetingInviteCategory =
        UNNotificationCategory(identifier: "MEETING_INVITATION",
                               actions: [acceptAction, declineAction],
                               intentIdentifiers: [],
                               hiddenPreviewsBodyPlaceholder: "",
                               options: .customDismissAction)
        // Register the notification type.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.setNotificationCategories([meetingInviteCategory])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                didReceive response: UNNotificationResponse,
                withCompletionHandler completionHandler:
                   @escaping () -> Void) {
        print("didReceive: userNotificationCenter")
        
       // Get the meeting ID from the original notification.
       let userInfo = response.notification.request.content.userInfo
            
       if response.notification.request.content.categoryIdentifier ==
                  "MEETING_INVITATION" {
          // Retrieve the meeting details.
          let meetingID = userInfo["MEETING_ID"] as! String
          let userID = userInfo["USER_ID"] as! String
                
          switch response.actionIdentifier {
          case "ACCEPT_ACTION":
              print("didReceive: accept")
             break
                    
          case "DECLINE_ACTION":
             print("didReceive: decline")
             break
                    
          case UNNotificationDefaultActionIdentifier,
               UNNotificationDismissActionIdentifier:
             // Queue meeting-related notifications for later
             //  if the user does not act.
              print("didReceive: something")
             break
                    
          default:
             break
          }
       }
       else {
          // Handle other notification types...
       }
            
       // Always call the completion handler when done.
       completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
             willPresent notification: UNNotification,
             withCompletionHandler completionHandler:
                @escaping (UNNotificationPresentationOptions) -> Void) {
        print("willPresent: userNotificationCenter")
        
       if notification.request.content.categoryIdentifier ==
                "MEETING_INVITATION" {
          // Retrieve the meeting details.
          let meetingID = notification.request.content.userInfo["MEETING_ID"] as! String
          let userID = notification.request.content.userInfo["USER_ID"] as! String
                
          // Add the meeting to the queue.
//          sharedMeetingManager.queueMeetingForDelivery(user: userID,
//                meetingID: meetingID)


          // Play a sound to let the user know about the invitation.
          completionHandler(.sound)
          return
       }
       else {
          // Handle other notification types...
       }


       // Don't alert the user for other types.
       completionHandler(UNNotificationPresentationOptions(rawValue: 0))
    }
    
}
