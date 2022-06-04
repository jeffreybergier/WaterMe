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
import Settings

internal struct Settings: View {

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
                    ForEach(4..<24) {
                        Text("\($0)").tag($0)
                    }
                } label: {
                    Text("Remind at")
                }
                // Reminder Days
                Picker(selection: self.$reminderDays) {
                    ForEach(7..<22) {
                        Text("\($0) days").tag($0)
                    }
                } label: {
                    Text("Remind for")
                }
                // Cloud Sync
                Toggle(isOn: self.$cloudSync) {
                    Text("Sync via iCloud")
                }
                // Ask for notifications
                Toggle(isOn: self.$askForNotifications) {
                    Text("Ask for Notifications")
                }
                // Check for Updates
                Toggle(isOn: self.$checkForUpdates) {
                    Text("Check for Updates")
                }
                // Reduce Pink / Increase Contrast
                Toggle(isOn: self.$increaseContrast) {
                    Text("Reduce Pink")
                }
                // Dark Mode
                Picker(selection: self.$darkMode) {
                    ForEach(DarkModeOverride.allCases) {
                        switch $0 {
                        case .system:
                            Text("System").tag($0)
                        case .forceLight:
                            Text("Always Light").tag($0)
                        case .forceDark:
                            Text("Always Dark").tag($0)
                        }
                    }
                } label: {
                    Text("Dark Mode")
                }
            }
            .modifier(XPDoneToolbar { self.dismiss() })
        }
    }
}
