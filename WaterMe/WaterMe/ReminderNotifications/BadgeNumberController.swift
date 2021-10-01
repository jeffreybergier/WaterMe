//
//  BadgeNumberController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 7/2/18.
//  Copyright © 2018 Saturday Apps.
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

import Datum
import UserNotifications
import UIKit
import Calculate

enum BadgeNumberController {

    private static let taskName = String(describing: BadgeNumberController.self) + "_SerialQueue_" + UUID().uuidString
    private static let queue = DispatchQueue(label: taskName, qos: .utility)
    private static var backgroundTaskID: UIBackgroundTaskIdentifier?

    static func perform(with values: [ReminderAndVesselValue]) {
        // make sure there isn't already a background task in progress
        guard self.backgroundTaskID == nil else {
            Analytics.log(event: Analytics.NotificationPermission.scheduleAlreadyInProgress)
            "Background task already in progress. Bailing.".log(as: .info)
            return
        }
        // make sure we're authorized to badge the icon
        guard case .enabled = UNUserNotificationCenter.current().notificationBadgeStatus else {
            Analytics.log(event: Analytics.NotificationPermission.scheduleBadgeIconDeniedBySystem)
            "User has disabled badge allowance".log(as: .info)
            return
        }
        self.backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: self.taskName,
                                                                         expirationHandler: nil)
        self.queue.async {
            let remindersThatNeedToBeDoneBeforeTomorrow = values.filter { value -> Bool in
                let cal = Calendar.current
                let now = Date()
                let endOfToday = cal.endOfDay(for: now)
                // if there is no nextPerformDate, it needs to be performed, so treat it as such
                guard let testDate = value.reminder.nextPerformDate else { return true }
                // otherwise check to see if the date is before the end of today
                let interval = endOfToday.timeIntervalSince(testDate)
                let test = interval >= 0
                return test
            }
            let count = remindersThatNeedToBeDoneBeforeTomorrow.count
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = count
                // end the background task
                guard let id = self.backgroundTaskID else { return }
                self.backgroundTaskID = nil
                UIApplication.shared.endBackgroundTask(id)
            }
        }
    }
}
