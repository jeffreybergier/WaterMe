//
//  Created by Jeffrey Bergier on 2022/11/12.
//
//  Copyright © 2020 Saturday Apps.
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
import V3Model
import V3Datum
import V3Style
import V3Localize

internal struct ReminderEdit: View {
    
    @Nav private var nav
    @V3Style.ReminderEdit private var style
    @V3Localize.ReminderEdit private var text
    
    @ReminderQuery private var reminder
    
    private let id: Reminder.Identifier
    
    internal init(_ id: Reminder.Identifier) {
        self.id = id
    }
    
    internal var body: some View {
        self.$reminder.view { item in
            Form {
                Section {
                    Picker(selection: item.kind) {
                        ForEach(Reminder.Kind.allCases) {
                            Text(String(describing: $0))
                                .tag($0)
                        }
                    } label: {
                        Text("Kind of Reminder")
                    }
                } header: {
                    Text("Kind of Reminder")
                }
                Section {
                    Picker(selection: item.interval) {
                        ForEach(kIntervalRange) {
                            Text(String(describing: $0))
                                .tag($0)
                        }
                    } label: {
                        Text("Remind Every")
                    }
                } header: {
                    Text("Remind Every")
                }
                Section {
                    Toggle(isOn: item.isEnabled.flipped) {
                        Text("Pause Notifications")
                    }
                } header: {
                    Text("Notifications")
                }
                Section {
                    TextField(text: item.note.compactMap(), prompt: nil) {
                        Text("Notes")
                    }
                } header: {
                    Text("Notes")
                }
                // TODO: Add Siri Shortcuts Here
                Section {
                    Text(String(describing: item.lastPerformDate.wrappedValue))
                } header: {
                    Text("Last Performed")
                }
            }
        } onNIL: {
            self.style.fallback
                      .action(text: self.text.itemNotFound)
                      .label
        }
        .modifier(self.toolbar)
        .onLoadChange(of: self.id) {
            _reminder.setIdentifier($0)
        }
    }
    
    private var toolbar: JSBToolbar {
        return JSBToolbar(
            title: self.text.title,
            delete: self.text.delete,
            deleteAction: {
                // TODO: Hookup error
                NSLog("Delete Me")
            }
        )
    }
}

private let kIntervalRange: Range<Int> = Reminder.Constants.minimumInterval ..< Reminder.Constants.maximumInterval + 1
