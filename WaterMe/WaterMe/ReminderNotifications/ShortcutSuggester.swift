//
//  ShortcutSuggester.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 10/14/18.
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

import DatumL
import Intents
import Calculate

protocol ShortcutSuggesterProtocol {
    static func perform(with values: [ReminderAndVesselValue])
    static func deleteActivities(for vessels: Set<ReminderVesselValue>)
    static func deleteActivities(for reminders: Set<ReminderValue>)
}

@available(iOS 12.0, *)
class ShortcutSuggester: ShortcutSuggesterProtocol {

    private static let taskName = String(describing: ShortcutSuggester.self) + "_SerialQueue_" + UUID().uuidString
    private static let queue = DispatchQueue(label: taskName, qos: .utility)
    private static var backgroundTaskID: UIBackgroundTaskIdentifier?

    class func deleteActivities(for reminders: Set<ReminderValue>) {
        let ids = reminders.flatMap { reminder in
            return [
                NSUserActivity.uniqueString(for: .editReminder,
                                            and: [reminder.uuid]),
                NSUserActivity.uniqueString(for: .viewReminder,
                                            and: [reminder.uuid]),
                NSUserActivity.uniqueString(for: .performReminder,
                                            and: [reminder.uuid]),
            ]
        }
        NSUserActivity.deleteSavedUserActivities(withPersistentIdentifiers: ids,
                                                 completionHandler: {})
    }

    class func deleteActivities(for vessels: Set<ReminderVesselValue>) {
        let ids = vessels.map({ NSUserActivity.uniqueString(for: .editReminderVessel,
                                                            and: [$0.uuid]) })
        NSUserActivity.deleteSavedUserActivities(withPersistentIdentifiers: ids,
                                                 completionHandler: {})
    }

    class func perform(with values: [ReminderAndVesselValue]) {
        // make sure there isn't already a background task in progress
        guard self.backgroundTaskID == nil else {
            Analytics.log(event: Analytics.NotificationPermission.scheduleAlreadyInProgress)
            "Background task already in progress. Bailing.".log(as: .info)
            return
        }
        self.backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: self.taskName,
                                                                         expirationHandler: nil)
        self.queue.async {
            self.raw_perform(with: values)
            DispatchQueue.main.async {
                guard let id = self.backgroundTaskID else { return }
                self.backgroundTaskID = nil
                UIApplication.shared.endBackgroundTask(id)
            }
        }
    }

    private static var delegates = [ReminderAndVesselValue: UserActivityConfiguratorProtocol]()

    private class func raw_perform(with values: [ReminderAndVesselValue]) {

        self.delegates = Dictionary(minimumCapacity: values.count)
        values.forEach { value in
            let delegate: UserActivityConfiguratorProtocol = UserActivityConfigurator()
            delegate.requiresMainThreadExecution = false
            delegate.currentReminderAndVessel = {
                return value
            }
            delegate.currentReminderVessel = {
                return value.reminderVessel
            }
            self.delegates[value] = delegate
        }

        let viewReminderShortcuts = values.compactMap {
            return INShortcut(kind: .viewReminder,
                              value: $0,
                              delegate: self.delegates[$0])

        }
        let editReminderShortcuts = values.compactMap {
            return INShortcut(kind: .editReminder,
                              value: $0,
                              delegate: self.delegates[$0])
        }
        let editReminderVesselShortcuts = values.compactMap {
            return INShortcut(kind: .editReminderVessel,
                              value: $0,
                              delegate: self.delegates[$0])
        }
        let performReminderShortcuts = values.compactMap {
            return INShortcut(kind: .performReminder,
                              value: $0,
                              delegate: self.delegates[$0])
        }

        assert({
            let valuesCount = values.count
            return viewReminderShortcuts.count == valuesCount
                && editReminderShortcuts.count == valuesCount
                && editReminderVesselShortcuts.count == valuesCount
                && performReminderShortcuts.count == valuesCount

        }())
        let allShortcuts = viewReminderShortcuts
                + editReminderShortcuts
                + editReminderVesselShortcuts
                + performReminderShortcuts

        INVoiceShortcutCenter.shared.setShortcutSuggestions(allShortcuts)
        self.delegates = [:]
        "Shortcut Items Suggested: \(allShortcuts.count)".log(as: .debug)
    }
}

@available(iOS 12.0, *)
extension INShortcut {

    fileprivate init?(kind: RawUserActivity,
                      value: ReminderAndVesselValue,
                      delegate: UserActivityConfiguratorProtocol?)
    {
        guard let delegate = delegate else { return nil }
        let activity = NSUserActivity(kind: kind, delegate: delegate)
        // Force values to save immediately
        // This prevents console log output that said the
        // INShortcuts were invalid because of missing title
        delegate.userActivityWillSave?(activity)
        self.init(userActivity: activity)
    }
}
