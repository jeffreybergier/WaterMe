//
//  Created by Jeffrey Bergier on 2022/06/04.
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
import Umbrella
import Settings

@propertyWrapper
public struct Settings: DynamicProperty {

    public struct Value {
        public var title: LocalizationKey = Label.settings
        public var labelReminderHour: LocalizationKey = Label.remindAt
        public var labelReminderDays: LocalizationKey = Label.remindFor
        public var labelCloudSync: LocalizationKey = Label.syncViaiCloud
        public var labelAskForNotifications: LocalizationKey = Label.askForNotifications
        public var labelCheckForUpdates: LocalizationKey = Label.checkForUpdates
        public var labelIncreaseContrast: LocalizationKey = Label.increaseContrast
        public var labelDarkMode: LocalizationKey = Label.darkMode

    }

    @EnvironmentBundle<LocalizeBundle> private var bundle

    public init() {}

    public var wrappedValue: (KeyPath<Value, LocalizationKey>) -> LocalizedString {{
        self.bundle.localized(key: Value()[keyPath: $0])
    }}

    public func hours(_ input: Hours) -> LocalizedString {
        self.bundle.localized(key: input.localized)
    }

    public func days(_ input: Days) -> LocalizedString {
        self.bundle.localized(key: input.localized)
    }

    public func darkMode(_ input: DarkModeOverride) -> LocalizedString {
        self.bundle.localized(key: input.localized)
    }
}
