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
import Umbrella
import Errors
import Datum
import Model
import Nav
import Style
import Localize

internal struct ReminderEdit: View {
    
    internal struct Presentation: ViewModifier {
        @NavReminderEdit private var nav
        internal func body(content: Content) -> some View {
            content
                .modifier(Alert(self.$nav.isError))
                .modifier(OnAppearErrorHandler())
        }
    }
    
    @ReminderEditQuery var reminder: Reminder
    
    @UFErrorQ private var errorQ
    @Style.Form private var style
    @Localize.ReminderEdit private var text
    @ControllerProperty private var controller
    @Environment(\.dismiss) private var dismiss
    
    internal init(id: Reminder.アイディ) {
        _reminder = ReminderEditQuery(id: id)
    }
    
    internal var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker(selection: self.$reminder.interval) {
                        ForEach(ReminderConstants.minimumInterval..<ReminderConstants.maximumInterval) {
                            Text(self._text.subsectionDataInterval($0))
                                .tag($0)
                        }
                    } label: {
                        Text(self.text(\.subsectionTitleInterval))
                    }
                    .modifier(self.style.subsectionData)
                    
                    Picker(selection: self.$reminder.kind) {
                        ForEach(Model.ReminderKind.allCases) {
                            Text(self._text.subsectionDataKind($0))
                                .tag($0)
                        }
                    } label: {
                        Text(self.text(\.subsectionTitleKind))
                    }
                    .modifier(self.style.subsectionData)
                    
                    if case .move = self.reminder.kind {
                        JSBTextField(self.text(\.subsectionPlaceholderMoveTo),
                                     text: self.$reminder.kindDescription)
                            .modifier(self.style.subsectionData)
                    }
                    if case .other = self.reminder.kind {
                        JSBTextField(self.text(\.subsectionPlaceholderDescription),
                                     text: self.$reminder.kindDescription)
                            .modifier(self.style.subsectionData)
                        
                    }
                } header: {
                    Text(self.text(\.sectionTitleDetails))
                        .modifier(self.style.sectionTitle)
                }
                Section {
                    JSBToggle(self.text(\.subsectionTitleNotifications),
                              isOn: self.$reminder.isEnabled, isFlipped: true)
                        .modifier(self.style.subsectionData)
                } header: {
                    Text(self.text(\.sectionTitleNotifications))
                        .modifier(self.style.sectionTitle)
                }
                Section {
                    JSBTextEditor(text: self.$reminder.note)
                        .modifier(self.style.textEditorMinHeight)
                        .modifier(self.style.subsectionData)
                } header: {
                    Text(self.text(\.sectionTitleNotes))
                        .modifier(self.style.sectionTitle)
                }
                XPSiriShortcuts()
                Section {
                    JSBText(self.text(\.subsectionPlaceholderLastPerformed),
                            text: self._text.subsectionDataLastPerformed(self.reminder.lastPerformDate))
                        .modifier(self.style.subsectionData)
                } header: {
                    Text(self.text(\.sectionTitleLastPerformed))
                        .modifier(self.style.sectionTitle)
                }
            }
            .navigationTitle(self.text(\.title))
            .modifier(XPDoneDeleteToolbar(
                onDone: { self.dismiss() },
                onDelete: .generic {
                    self.controller.delete(self.reminder.id).error
                        .map { self.errorQ.append($0) }
                }
            ))
            .onChange(of: self.reminder.isDeleted) { isDeleted in
                guard isDeleted else { return }
                self.dismiss()
            }
        }
    }
}
