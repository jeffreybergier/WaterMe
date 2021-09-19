//
//  UserDefaults.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/7/17.
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

import Foundation
import Datum

extension UserDefaults {
    
    enum Constants {
        static let kFirstRun = "FIRST_RUN"
        static let kCloudSync = "CLOUD_SYNC"
        static let kCloudSyncInfoShown = "CLOUD_SYNC_INFO_SHOWN"
        static let kReminderHour = "REMINDER_HOUR"
        static let kNumberOfReminderDays = "NUMBER_OF_REMINDER_DAYS"
        static let kIncreaseContrast = "INCREASE_CONTRAST"
        static let kDarkMode = "DARK_MODE"
        static let kBuildNumberKey = "LAST_BUILD_NUMBER"
        static let kRequestReviewDate = "REQUEST_REVIEW_DATE"
        static let kCheckForUpdatesOnLaunch = "CHECK_FOR_UPDATES"
        // Make sure this stays in sync with BasicWrappers.swift file
        static let kDidRunWithoutCloudSync = "DID_RUN_WITHOUT_CLOUD_SYNC"
    }

    var checkForUpdatesOnLaunch: Bool {
        get {
            guard let number = self.object(forKey: Constants.kCheckForUpdatesOnLaunch) as? NSNumber
                else { fatalError("Must call configure() before accessing user defaults") }
            return number.boolValue
        }
        set {
            self.set(NSNumber(value: newValue), forKey: Constants.kCheckForUpdatesOnLaunch)
        }
    }

    var requestReviewDate: Date? {
        get {
            return self.object(forKey: Constants.kRequestReviewDate) as? Date
        }
        set {
            self.set(newValue, forKey: Constants.kRequestReviewDate)
        }
    }

    var lastBuildNumber: Int? {
        get {
            return (self.object(forKey: Constants.kBuildNumberKey) as? NSNumber)?.intValue
        }
        set {
            guard let newValue = newValue else {
                self.set(nil, forKey: Constants.kBuildNumberKey)
                return
            }
            self.set(NSNumber(value: newValue), forKey: Constants.kBuildNumberKey)
        }
    }

    var increaseContrast: Bool {
        get {
            guard let number = self.object(forKey: Constants.kIncreaseContrast) as? NSNumber
                else { fatalError("Must call configure() before accessing user defaults") }
            let systemSetting = UIAccessibility.isDarkerSystemColorsEnabled
            if systemSetting == true {
                return systemSetting
            } else {
                return number.boolValue
            }
        }
        set {
            self.set(NSNumber(value: newValue), forKey: Constants.kIncreaseContrast)
        }
    }

    var darkMode: DarkMode {
        get {
            guard let number = self.object(forKey: Constants.kDarkMode) as? NSNumber
                else { fatalError("Must call configure() before accessing user defaults") }
            return DarkMode(rawValue: number.intValue) ?? .system
        }
        set {
            self.set(NSNumber(value: newValue.rawValue), forKey: Constants.kDarkMode)
        }
    }
    
    var askForNotifications: Bool {
        get {
            guard let number = self.object(forKey: Constants.kFirstRun) as? NSNumber
                else { fatalError("Must call configure() before accessing user defaults") }
            return number.boolValue
        }
        set {
            self.set(NSNumber(value: newValue), forKey: Constants.kFirstRun)
        }
    }
    
    var controllerKind: ControllerKind {
        get {
            guard let number = self.object(forKey: Constants.kCloudSync) as? NSNumber
                else { fatalError("Must call configure() before accessing user defaults") }
            return .init(rawValue: number.boolValue)
        }
        set {
            self.set(NSNumber(value: newValue.rawValue), forKey: Constants.kCloudSync)
        }
    }
    
    var hasCloudSyncInfoShown: Bool {
        get {
            guard #available(iOS 14, *) else { return true }
            guard let number = self.object(forKey: Constants.kCloudSyncInfoShown) as? NSNumber
                else { fatalError("Must call configure() before accessing user defaults") }
            return number.boolValue
        }
        set {
            guard #available(iOS 14, *) else { return }
            self.set(NSNumber(value: newValue), forKey: Constants.kCloudSyncInfoShown)
        }
    }
    
    var reminderHour: Int {
        get {
            guard let number = self.object(forKey: Constants.kReminderHour) as? NSNumber
                else { fatalError("Must call configure() before accessing user defaults") }
            return number.intValue
        }
        set {
            self.set(NSNumber(value: newValue), forKey: Constants.kReminderHour)
        }
    }
    
    var reminderDays: Int {
        get {
            guard let number = self.object(forKey: Constants.kNumberOfReminderDays) as? NSNumber
                else { fatalError("Must call configure() before accessing user defaults") }
            return number.intValue
        }
        set {
            self.set(NSNumber(value: newValue), forKey: Constants.kNumberOfReminderDays)
        }
    }
    
    func configure() {
        self.register(defaults: [
            Constants.kFirstRun                : true,
            Constants.kCloudSync               : true,
            Constants.kCloudSyncInfoShown      : true,
            Constants.kReminderHour            : 8,
            Constants.kNumberOfReminderDays    : 14,
            Constants.kIncreaseContrast        : false,
            Constants.kDarkMode                : 0,
            Constants.kCheckForUpdatesOnLaunch : true,
            Constants.kDidRunWithoutCloudSync  : true
        ])

        let build = self.lastBuildNumber
        
        if let build = build, build <= 201027 {
            // fix bug where this toggle is always off in v1.0 and it needs to be on in 2.0
            self.askForNotifications = true
        }
        
        if let build = build {
            // if the user is upgrading from an old build then mark this
            // info screen as not seen.
            // For new users, use the default of TRUE (already seen)
            // as new users don't need to be concerned.
            if build < 280043 {
                self.hasCloudSyncInfoShown = false
                // if they are running an old version of iOS also disable Cloud Sync
                if #available(iOS 14, *) { /* Do Nothing */ } else {
                    self.controllerKind = .local
                }
            }
        } else {
            // if this is a fresh install on an old version of iOS,
            // force disable cloud sync
            if #available(iOS 14, *) { /* Do Nothing */ } else {
                self.controllerKind = .local
            }
        }
    }

    enum DarkMode: Int {
        case system = 0
        case forceLight = 1
        case forceDark = 2
    }

    // MARK: For KVO only, do not use
    @objc dynamic var INCREASE_CONTRAST: Any { fatalError() }
    @objc dynamic var DARK_MODE: Any { fatalError() }
    @objc dynamic var NUMBER_OF_REMINDER_DAYS: Any { fatalError() }
    @objc dynamic var REMINDER_HOUR: Any { fatalError() }
    @objc dynamic var FIRST_RUN: Any { fatalError() }
    @objc dynamic var CLOUD_SYNC: Any { fatalError() }
}
