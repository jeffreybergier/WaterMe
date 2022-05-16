//
//  Created by Jeffrey Bergier on 2021/12/31.
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
import Model
import Datum
import Nav
import Umbrella

internal struct ReminderEdit: View {

    @ReminderEditQuery var reminder: Reminder
    @Environment(\.dismiss) private var dismiss

    internal init(id: Reminder.アイディ, controller: AnyController) {
        _reminder = ReminderEditQuery(id: id, controller: controller)
    }

    internal var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Kind of Reminder")) {
                    Picker("Kind of Reminder", selection: self.$reminder.kind) {
                        ForEach(ReminderKind.allCases) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                }
                if case .move = self.reminder.kind {
                    Section(header: Text("Details")) {
                        JSBTextField("Move to", text: self.$reminder.kindDescription)
                    }
                }
                if case .other = self.reminder.kind {
                    Section(header: Text("Details")) {
                        JSBTextField("Description", text: self.$reminder.kindDescription)
                    }
                }
                Section(header: Text("Remind Every")) {
                    Picker("Remind Every", selection: self.$reminder.interval) {
                        ForEach(ReminderConstants.minimumInterval..<ReminderConstants.maximumInterval) {
                            Text(String($0)).tag($0)
                        }
                    }
                }
                Section(header: Text("Notifications")) {
                    JSBToggle("Pause Notifications", isOn: self.$reminder.isEnabled, isFlipped: true)
                }
                Section(header: Text("Notes")) {
                    JSBTextField("Notes", text: self.$reminder.note)
                }
                Section(header: Text("Siri Shortcuts")) {
                    Text("// TODO: Siri Shortcuts")
                }
                Section(header: Text("Last Performed")) {
                    JSBText("Never", text: self.reminder.lastPerformDate?.description)
                }
            }
            .navigationTitle("Edit Reminder")
            .toolbar {
                Button("Done") { self.dismiss() }
            }
        }
    }
}
