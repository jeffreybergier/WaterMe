//
//  CoreSpotlightIndexer.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 10/3/18.
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
import CoreSpotlight
import MobileCoreServices
import Calculate

class CoreSpotlightIndexer {

    private static let taskName = String(describing: CoreSpotlightIndexer.self) + "_SerialQueue_" + UUID().uuidString
    private static let queue = DispatchQueue(label: taskName, qos: .utility)
    private static var backgroundTaskID: UIBackgroundTaskIdentifier?

    class func perform(with values: [ReminderAndVesselValue]) {
        // make sure we can index
        guard CSSearchableIndex.isIndexingAvailable() else {
            "Indexing not available on this device".log(as: .info)
            return
        }
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

    private class func raw_perform(with values: [ReminderAndVesselValue]) {
        let index = CSSearchableIndex.default()
        let deleteError = index.sync_deleteAllSearchableItems()
        if let error = deleteError {
            error.log()
            Analytics.log(error: error)
            assertionFailure(String(describing: error))
            return
        }
        let reminderItems = CSSearchableItem.items(from: values)
        let reminderIndexError = index.sync_indexSearchableItems(items: reminderItems)
        if let error = reminderIndexError {
            error.log()
            Analytics.log(error: error)
            assertionFailure(String(describing: error))
            return
        }
        "Spotlight Items Indexed: \(reminderItems.count)".log(as: .debug)
    }
}

extension CSSearchableIndex {

    fileprivate func sync_deleteAllSearchableItems() -> Error? {
        var error: Error?
        let semaphore = DispatchSemaphore(value: 0)
        self.deleteAllSearchableItems() { _error in
            error = _error
            semaphore.signal()
        }
        semaphore.wait()
        return error
    }

    fileprivate func sync_indexSearchableItems(items: [CSSearchableItem]) -> Error? {
        var error: Error?
        let semaphore = DispatchSemaphore(value: 0)
        self.indexSearchableItems(items) { _error in
            error = _error
            semaphore.signal()
        }
        semaphore.wait()
        return error
    }

}

extension CSSearchableItem {

    fileprivate class func items(from values: [ReminderAndVesselValue]) -> [CSSearchableItem] {
        return values.map() { value -> CSSearchableItem in
            let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeContent as String)
            attributes.title = UserActivityConfigurator.LocalizedString.viewReminderTitle(for: value.reminder.kind,
                                                                                          andVesselName: value.reminderVessel.name)
            attributes.contentDescription = CoreSpotlightIndexer.LocalizedString.description
            attributes.thumbnailData = value.reminderVessel.imageData
            let uuid = NSUserActivity.uniqueString(for: RawUserActivity.viewReminder,
                                                   and: [value.reminder.uuid])
            let item = CSSearchableItem(uniqueIdentifier: uuid,
                                        domainIdentifier: RawUserActivity.viewReminder.rawValue,
                                        attributeSet: attributes)
            return item
        }
    }
}
