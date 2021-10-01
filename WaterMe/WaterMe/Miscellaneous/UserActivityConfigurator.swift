//
//  UserActivityConfigurator.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/29/18.
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
import Foundation
import Calculate

protocol UserActivityConfiguratorProtocol: NSUserActivityDelegate {
    var currentReminderAndVessel: (() -> ReminderAndVesselValue?)? { get set }
    var currentReminderVessel: (() -> ReminderVesselValue?)? { get set }
    var requiresMainThreadExecution: Bool { get set }
}

class UserActivityConfigurator: NSObject, UserActivityConfiguratorProtocol {
    var currentReminderAndVessel: (() -> ReminderAndVesselValue?)?
    var currentReminderVessel: (() -> ReminderVesselValue?)?
    var requiresMainThreadExecution = true
}

extension UserActivityConfigurator: NSUserActivityDelegate {
    func userActivityWillSave(_ activity: NSUserActivity) {
        let workItem = {
            guard let kind = RawUserActivity(rawValue: activity.activityType) else {
                assertionFailure("Unsupported User Activity Type")
                return
            }

            let reminderVessel = self.currentReminderVessel?()
            let reminder = self.currentReminderAndVessel?()

            switch kind {
            case .editReminderVessel:
                self.updateEditReminderVessel(activity: activity,
                                              reminderVessel: reminderVessel)
            case .editReminder:
                self.updateEditReminder(activity: activity, value: reminder)
            case .viewReminder:
                self.updateViewReminder(activity: activity, value: reminder)
            case .performReminder:
                self.updatePerformReminder(activity: activity,
                                           value: reminder)
            case .indexedItem:
                assertionFailure("Cannot update the data on a CoreSpotlight activity")
            }
        }
        // check if we're NOT on the main thread
        // if we are just, execute the workitem
        guard DispatchQueue.isMain == false else {
            workItem()
            return
        }
        // check if the user of this class needs
        // the execution to happen on the main thread
        // if they don't, just execute the work item
        guard self.requiresMainThreadExecution else {
            workItem()
            return
        }
        // now hop on the main thread and execute
        DispatchQueue.main.sync {
            workItem()
            return
        }
    }
}

private extension UserActivityConfigurator {

    private func updateEditReminderVessel(activity: NSUserActivity, reminderVessel: ReminderVesselValue?) {
        assert(activity.activityType == RawUserActivity.editReminderVessel.rawValue)
        guard let reminderVessel = reminderVessel else {
            "Unable to save Activity: Missing Reminder Vessel".log(as: .debug)
            activity.waterme_isEligibleForNeededServices = false
            return
        }

        activity.waterme_isEligibleForNeededServices = true

        let uuid = reminderVessel.uuid
        let title = LocalizedString.editVesselTitle(fromVesselName: reminderVessel.name)
        let phrase = LocalizedString.randomLocalizedPhrase
        let description = LocalizedString.editReminderVesselDescription

        activity.update(uuid: uuid,
                        title: title,
                        phrase: phrase,
                        description: description,
                        thumbnailData: reminderVessel.imageData)
    }

    private func updateViewReminder(activity: NSUserActivity, value: ReminderAndVesselValue?) {
        assert(activity.activityType == RawUserActivity.viewReminder.rawValue)
        guard let value = value else {
            "Unable to save Activity: Missing Reminder".log(as: .debug)
            activity.waterme_isEligibleForNeededServices = false
            return
        }

        activity.waterme_isEligibleForNeededServices = true

        let uuid = value.reminder.uuid
        let title = LocalizedString.viewReminderTitle(for: value.reminder.kind,
                                                      andVesselName: value.reminderVessel.name)
        let phrase = LocalizedString.randomLocalizedPhrase
        let description = LocalizedString.viewReminderDescription

        activity.update(uuid: uuid,
                        title: title,
                        phrase: phrase,
                        description: description,
                        thumbnailData: value.reminderVessel.imageData)
    }

    private func updatePerformReminder(activity: NSUserActivity,
                                       value: ReminderAndVesselValue?)
    {
        assert(activity.activityType == RawUserActivity.performReminder.rawValue)
        guard let value = value else {
            "Unable to save Activity: Missing Reminder".log(as: .debug)
            activity.waterme_isEligibleForNeededServices = false
            return
        }

        activity.waterme_isEligibleForNeededServices = true

        let uuid = value.reminder.uuid
        let title = LocalizedString.performReminderTitle(for: value.reminder.kind,
                                                         andVesselName: value.reminderVessel.name)
        let description = LocalizedString.performReminderDescription
        let phrase = LocalizedString.randomLocalizedPhrase
        activity.update(uuid: uuid,
                        title: title,
                        phrase: phrase,
                        description: description,
                        thumbnailData: value.reminderVessel.imageData)
    }

    private func updateEditReminder(activity: NSUserActivity,
                                    value: ReminderAndVesselValue?)
    {
        assert(activity.activityType == RawUserActivity.editReminder.rawValue)
        guard let value = value else {
            "Unable to save Activity: Missing Reminder".log(as: .debug)
            activity.waterme_isEligibleForNeededServices = false
            return
        }

        activity.waterme_isEligibleForNeededServices = true

        let uuid = value.reminder.uuid
        let title = LocalizedString.editReminderTitle(for: value.reminder.kind,
                                                      andVesselName: value.reminderVessel.name)
        let phrase = LocalizedString.randomLocalizedPhrase
        let description = LocalizedString.editReminderDescription

        activity.update(uuid: uuid,
                        title: title,
                        phrase: phrase,
                        description: description,
                        thumbnailData: value.reminderVessel.imageData)
    }
}
