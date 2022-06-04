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
import Localize
import Settings

internal struct Settings: View {

    @Localize.Settings private var loc
    @Environment(\.dismiss) private var dismiss

    @ReminderHour private var reminderHour
    @ReminderDaysCount private var reminderDays
    @CloudSync private var cloudSync
    @AskForNotifications private var askForNotifications
    @CheckForUpdatesOnLaunch private var checkForUpdates
    @IncreaseContrast private var increaseContrast
    @DarkMode private var darkMode

    internal var body: some View {
        NavigationView {
            Form {
                // Reminder Hour
                Picker(selection: self.$reminderHour) {
                    ForEach(Hours.allCases) {
                        Text(self._loc.hours($0)).tag($0)
                    }
                } label: {
                    Text(self.loc(\.labelReminderHour))
                }
                // Reminder Days
                Picker(selection: self.$reminderDays) {
                    ForEach(Days.allCases) {
                        Text(self._loc.days($0)).tag($0)
                    }
                } label: {
                    Text(self.loc(\.labelReminderDays))
                }
                // Cloud Sync
                Toggle(isOn: self.$cloudSync) {
                    Text(self.loc(\.labelCloudSync))
                }
                // Ask for notifications
                Toggle(isOn: self.$askForNotifications) {
                    Text(self.loc(\.labelAskForNotifications))
                }
                // Check for Updates
                Toggle(isOn: self.$checkForUpdates) {
                    Text(self.loc(\.labelCheckForUpdates))
                }
                // Reduce Pink / Increase Contrast
                Toggle(isOn: self.$increaseContrast) {
                    Text(self.loc(\.labelIncreaseContrast))
                }
                // Dark Mode
                Picker(selection: self.$darkMode) {
                    ForEach(DarkModeOverride.allCases) {
                        Text(self._loc.darkMode($0)).tag($0)

                    }
                } label: {
                    Text(self.loc(\.labelDarkMode))
                }
            }
            .navigationTitle(self.loc(\.title))
            .modifier(XPDoneToolbar { self.dismiss() })
        }
    }
}
