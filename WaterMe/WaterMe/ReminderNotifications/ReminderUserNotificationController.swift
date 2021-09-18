//
//  ReminderUserNotificationController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 03/11/17.
//  Copyright © 2017 Saturday Apps.
//
//  This file is part of WaterMe.  Simple Plant Watering Reminders for iOS.
//
//  WaterMe is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  WaterMe is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with WaterMe.  If not, see <http://www.gnu.org/licenses/>.
//

import UserNotifications
import Calculate

class ReminderUserNotificationController {

    private let taskName = String(describing: ReminderUserNotificationController.self) + "_SerialQueue_" + UUID().uuidString
    private lazy var queue = DispatchQueue(label: taskName, qos: .utility)
    private var backgroundTaskID: UIBackgroundTaskIdentifier?

    func perform(with values: [ReminderAndVesselValue]) {
        
        // get reusable objects
        let application = UIApplication.shared
        let calendar = Calendar.current
        let center = UNUserNotificationCenter.current()
        let now = Date()
        
        // make sure we have permission to schedule
        guard center.canScheduleNotifications else {
            Analytics.log(event: Analytics.NotificationPermission.permissionDenied)
            return
        }
        
        // make sure there isn't already a background task in progress
        guard self.backgroundTaskID == nil else {
            Analytics.log(event: Analytics.NotificationPermission.scheduleAlreadyInProgress)
            return
        }
        
        // tell the OS I'm running a background task
        self.backgroundTaskID = application.beginBackgroundTask(withName: self.taskName,
                                                                expirationHandler: nil)

        // clear already scheduled notifications as we're going to schedule new ones
        center.removeAllPendingNotificationRequests()
        // clear out all reminders except the newest one
        center.getDeliveredNotifications {
            let toDelete = $0.sorted { $0.date <= $1.date }
                             .dropLast()
                             .map { $0.request.identifier }
            guard !toDelete.isEmpty else { return }
            return // TODO: try and fix disappearing notification problem
            DispatchQueue.main.async {
                center.removeDeliveredNotifications(withIdentifiers: toDelete)
            }
        }
        
        // hop on a background queue to do the processing
        self.queue.async {
            // completion block for when things are finished
            let completion = {
                DispatchQueue.main.async {
                    // tell the OS I'm done with the background task
                    guard let id = self.backgroundTaskID else { return }
                    self.backgroundTaskID = nil
                    application.endBackgroundTask(id)
                }
            }

            // make sure we have data to work with before continuing
            guard values.isEmpty == false else {
                "Reminder array was empty".log(as: .debug)
                completion()
                return
            }

            // make sure we're authorized to send notifications
            guard center.notificationAuthorizationStatus.boolValue else {
                "User has turned System notification toggle off".log(as: .info)
                Analytics.log(event: Analytics.NotificationPermission.scheduleDeniedBySystem)
                completion()
                return
            }
            // generate notification object requests
            let requests = type(of: self).notificationRequests(from: values,
                                                               calendar: calendar,
                                                               now: now)
            Analytics.log(event: Analytics.NotificationPermission.scheduleSucceeded,
                          extras: Analytics.NotificationPermission.extras(forCount: requests.count))
            guard requests.isEmpty == false else {
                "No notifications to schedule".log(as: .debug)
                completion()
                return
            }

            // Schedule the notifications via notification center
            // This is an async loop powered by the completion handler
            // of the center.addRequest function
            var idx = 0
            var scheduleLoop: ((Error?) -> Void)!
            scheduleLoop = { error in
                if let error = error {
                    // error, time to bail
                    error.log()
                    Analytics.log(error: error)
                    assertionFailure()
                    completion()
                    // TODO: Add error for AppDelegate that main app knows about
                    return
                } else if idx < requests.count {
                    // get the request
                    let req = requests[idx]
                    // bump the loop count
                    idx += 1
                    // Schedule the notification
                    // Docs say this can be called from any thread
                    center.add(req) { error in
                        // In the completion handler, start the loop over.
                        // completion handler called on arbitrary thread
                        self.queue.async { scheduleLoop(error) }
                    }
                    return
                } else {
                    // finished successfully!
                    "Scheduled Notifications: \(requests.count)".log(as: .debug)
                    completion()
                    return
                }
            }
            scheduleLoop(nil)
        }
    }

    private class func notificationRequests(from values: [ReminderAndVesselValue],
                                            calendar: Calendar,
                                            now: Date) -> [UNNotificationRequest]
    {
        // make sure we have data to work with
        guard values.isEmpty == false else { return [] }

        // get preference values for reminder time and number of days to remind for
        let reminderHour = UserDefaults.standard.reminderHour
        let reminderDays = UserDefaults.standard.reminderDays
        let notificationLimit = UNUserNotificationCenter.notificationLimit

        // find the last reminder time and how many days away it is
        let numberOfDaysToLastReminder = values.last?.reminder.nextPerformDate.map() { endDate -> Int in
            return calendar.numberOfDaysBetween(startDate: now,
                                                endDate: endDate,
                                                stopCountingAfterMaxDays: notificationLimit - reminderDays)
        }
        // add that to the number of extra days the user requested
        let totalReminderDays = (numberOfDaysToLastReminder ?? 0) + reminderDays

        // batch all the reminders into days
        let matches = (0 ..< totalReminderDays).compactMap() { i -> (Date, [ReminderAndVesselValue])? in
            let testDate = calendar.date(byAdding: .day, value: i, to: now)!
            let endOfDayInTestDate = calendar.endOfDay(for: testDate)
            let matches = values.filter() { value -> Bool in
                let endOfDayInNextPerformDate = calendar.endOfDay(for: value.reminder.nextPerformDate ?? now)
                return endOfDayInNextPerformDate <= endOfDayInTestDate
            }
            guard matches.isEmpty == false else { return nil }
            let reminderTimeInSameDayAsTestDate = calendar.dateWithExact(hour: reminderHour, onSameDayAs: testDate)
            guard reminderTimeInSameDayAsTestDate >= now else { return nil }
            return (reminderTimeInSameDayAsTestDate, matches)
        }

        // convert the matches into one notification each
        let reminders = matches.compactMap() { reminderTime, matches -> UNNotificationRequest? in
            // construct the notification
            let _content = UNMutableNotificationContent()
            let dateComponents = calendar.userNotificationCompatibleDateComponents(with: reminderTime)
            let trigger = reminderTime >= now
                ? UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                : nil

            // shuffle the names so that different plant names show in the notifications
            let plantNames = ReminderAndVesselValue.uniqueParentPlantNames(from: matches).shuffled()

            // only set the body if there is a trigger. this way a notification won't be shown to the user
            // only the badge will update.
            _content.body = ReminderUserNotificationController.LocalizedString.localizedNotificationBody(from: plantNames)
            _content.sound = .default
            _content.badge = NSNumber(value: matches.count)

            // swiftlint:disable:next force_cast
            let content = _content.copy() as! UNNotificationContent
            let request = UNNotificationRequest(identifier: reminderTime.description,
                                                content: content,
                                                trigger: trigger)

            return request
        }

        // done!
        return reminders
    }
}

import Datum

extension ReminderUserNotificationController.LocalizedString {
    fileprivate static func localizedNotificationBody(from items: [String?]) -> String {
        switch items.count {
        case 1:
            let item1 = items[0] ?? LocalizedString.ReminderVessel.untitledPlant
            let string = String(format: self.bodyOneItem, item1)
            return string
        case 2:
            let item1 = items[0] ?? LocalizedString.ReminderVessel.untitledPlant
            let item2 = items[1] ?? LocalizedString.ReminderVessel.untitledPlant
            let string = String(format: self.bodyTwoItems, item1, item2)
            return string
        default:
            let item1 = items[0] ?? LocalizedString.ReminderVessel.untitledPlant
            let string = String(format: self.bodyManyItems, item1, items.count - 1)
            return string
        }
    }
}
