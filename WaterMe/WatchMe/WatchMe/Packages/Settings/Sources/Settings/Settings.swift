//
//  Created by Jeffrey Bergier on 2022/06/03.
//  Copyright © 2021 Saturday Apps.
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

import SwiftUI

//internal static let kFirstRun = "FIRST_RUN"
//internal static let kCloudSync = "CLOUD_SYNC"
//internal static let kCloudSyncInfoShown = "CLOUD_SYNC_INFO_SHOWN"
//internal static let kReminderHour = "REMINDER_HOUR"
//internal static let kNumberOfReminderDays = "NUMBER_OF_REMINDER_DAYS"
//internal static let kIncreaseContrast = "INCREASE_CONTRAST"
//internal static let kDarkMode = "DARK_MODE"
//internal static let kBuildNumberKey = "LAST_BUILD_NUMBER"
//internal static let kRequestReviewDate = "REQUEST_REVIEW_DATE"
//internal static let kCheckForUpdatesOnLaunch = "CHECK_FOR_UPDATES"
//// Make sure this stays in sync with BasicWrappers.swift file
//internal static let kDidRunWithoutCloudSync = "DID_RUN_WITHOUT_CLOUD_SYNC"

@propertyWrapper
public struct FirstRun: DynamicProperty {
    @AppStorage(UserDefaults.Constants.kFirstRun) private var value: Bool = false
    public init() {}
    public var wrappedValue: Bool {
        get { self.value }
        nonmutating set { self.value = newValue }
    }
    public var projectedValue: Binding<Bool> {
        self.$value
    }
}
