import SwiftUI
import UserNotifications
import CoreLocation

class NotificationManager {
    static let instance = NotificationManager()
    private init() {}
    
    func requestAuthorization(_ completion: @escaping (Bool) -> Void) {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (success, error) in
            if let error = error {
                completion(false)
                print(error.localizedDescription)
            } else {
                completion(success)
                print("SUCCESS")
            }
        }
    }
    
    func scheduleNotification(schedule: Schedulable, notification: any Notifiable) {
        let date = notification.notifyAt
        let content = UNMutableNotificationContent()
        content.title = schedule.name
        if let appointment = notification as? TAppointment {
            if let firstMember = appointment.members.first {
                if appointment.members.count > 1 {
                    content.subtitle = schedule.priority.title + " with " + firstMember.fullName + " +\(appointment.members.count - 1)"
                } else {
                    content.subtitle = schedule.priority.title + " with " + firstMember.fullName
                }
            } else {
                content.subtitle = schedule.priority.title
            }
        } else {
            content.subtitle = schedule.priority.title
        }
        
        content.body = notification.comment
        content.sound = .default
        
        // has no due date -> Repeat
        // has due date -> Loop to set(every week)
        // no repeat -> just once
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekday], from: date)
        
        if notification.shouldRepeat {
            if schedule.hasDeadline { // for-loop
                // TODO: IMPLEMENT
            } else {
                let dateComponents = DateComponents(hour: components.hour, minute: components.minute, second: 0, weekday: components.weekday)
                let currentTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: currentTrigger)
                UNUserNotificationCenter.current().add(request)
            }
        } else {
            let dateComponents = DateComponents(year: components.year, month: components.month, day: components.day, hour: components.hour, minute: components.minute, second: 0)
            let currentTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: currentTrigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    func cancelNotification(notification: any Notifiable) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.id])
    }
    
    func cancelAll() {
        UNUserNotificationCenter.current()
            .removeAllPendingNotificationRequests()
    }
}
