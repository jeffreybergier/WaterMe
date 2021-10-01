//
//  GlobalReminderObserver.swift
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

import Calculate
import Datum
import UserNotifications

class GlobalReminderObserver {

    enum DataKind {
        case badge, notifications, systemIndexes, all
    }

    private let spotlightIndexer = CoreSpotlightIndexer.self
    private let shortcutSuggester: ShortcutSuggesterProtocol.Type? = {
        guard #available(iOS 12.0, *) else { return nil }
        return ShortcutSuggester.self
    }()
    private let badgeNumberController = BadgeNumberController.self
    private let notificationController = ReminderUserNotificationController()
    private let significantTimePassedDetector = SignificantTimePassedDetector()
    private let basicRC: BasicController

    private var data: ReminderCollection?
    private var timer: Timer?

    private let taskName = String(describing: GlobalReminderObserver.self) + UUID().uuidString
    private var backgroundTaskID: UIBackgroundTaskIdentifier?

    init?(result: Result<BasicController, DatumError>) {
        guard let basicController = result.value else { return nil }
        self.basicRC = basicController
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.applicationDidEnterBackground(with:)),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        self.significantTimePassedDetector.delegate = self

        self.basicRC.reminderVesselsDeleted = { [weak self] vessels in
            self?.shortcutSuggester?.deleteActivities(for: vessels)
        }
        self.basicRC.remindersDeleted = { [weak self] reminders in
            self?.shortcutSuggester?.deleteActivities(for: reminders)
        }
        let collection = basicController.enabledReminders(sorted: .nextPerformDate, ascending: true).value
        self.token = collection?.observe({ [weak self] in self?.dataChanged($0) })
        self.resetTimer()
    }

    func notificationPermissionsMayHaveChanged() {
        self.resetTimer()
    }

    private func dataChanged(_ changes: ReminderCollectionChange) {
        switch changes {
        case .initial(let data):
            self.data = data
        case .update:
            self.resetTimer()
        case .error(let error):
            self.data = nil
            self.token?.invalidate()
            self.token = nil
            Analytics.log(error: error)
            error.log()
        }
    }

    func dataChanged(of kind: DataKind) {
        // make sure there isn't already a background task in progress
        guard self.backgroundTaskID == nil else {
            Analytics.log(event: Analytics.NotificationPermission.scheduleAlreadyInProgress)
            "Background task already in progress. Bailing.".log(as: .info)
            return
        }
        // start a background task
        self.backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: self.taskName,
                                                                         expirationHandler: nil)
        let data = Array(self.data?.compactMap({ ReminderAndVesselValue(reminder: $0) }) ?? [])
        switch kind {
        case .notifications:
            self.notificationController.perform(with: data)
        case .badge:
            self.badgeNumberController.perform(with: data)
        case .systemIndexes:
            self.spotlightIndexer.perform(with: data)
            self.shortcutSuggester?.perform(with: data)
        case .all:
            self.notificationController.perform(with: data)
            self.spotlightIndexer.perform(with: data)
            self.shortcutSuggester?.perform(with: data)
            self.badgeNumberController.perform(with: data)
        }
        // end the background task
        guard let id = self.backgroundTaskID else { return }
        self.backgroundTaskID = nil
        UIApplication.shared.endBackgroundTask(id)
    }

    private func resetTimer() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
            timer.invalidate()
            self.timer?.invalidate()
            self.timer = nil
            self.dataChanged(of: .all)
        }
    }

    @objc private func applicationDidEnterBackground(with notification: Notification?) {
        self.timer?.fire()
    }

    private var token: ObservationToken?

    deinit {
        self.token?.invalidate()
    }
}

extension GlobalReminderObserver: SignificantTimePassedDetectorDelegate {
    // when the data is stale because of significant time passing, we need to refresh the app icon
    func significantTimeDidPass(with _: SignificantTimePassedDetector.Reason,
                                detector _: SignificantTimePassedDetector)
    {
        self.dataChanged(of: .badge)
    }
}
