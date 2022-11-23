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
import V3Nav
import V3Model
import V3Datum
import V3Style
import V3Localize

internal struct ReminderEdit: View {
    
    private static let kIntervalRange: Range<Int> = Reminder.Constants.minimumInterval ..< Reminder.Constants.maximumInterval + 1
    
    @Nav private var nav
    @V3Style.ReminderEdit private var style
    @V3Localize.ReminderEdit private var text
    
    @Environment(\.errorResponder) private var errorResponder
    
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
                        ForEach(self.kinds, id: \.0) { kind, text in
                            self.style.picker
                                .action(text: text)
                                .label
                                .tag(kind)
                        }
                    } label: {
                        self.style.contentLabel
                            .action(text: self.text.kind)
                            .label
                    }
                    Picker(selection: item.interval) {
                        ForEach(ReminderEdit.kIntervalRange) {
                            self.style.picker
                                .action(text: self.text.intervalString($0))
                                .label
                                .tag($0)
                        }
                    } label: {
                        self.style.contentLabel
                            .action(text: self.text.interval)
                            .label
                    }
                    Toggle(isOn: item.isEnabled.flipped) {
                        self.style.contentLabel
                            .action(text: self.text.pause)
                            .label
                    }
                } header: {
                    self.style.sectionHeader
                        .action(text: self.text.reminder)
                        .label
                }
                Section {
                    TextField(self.text.notes.title,
                              text: item.note.compactMap())
                } header: {
                    self.style.sectionHeader
                        .action(text: self.text.notes)
                        .label
                }
                // TODO: Add Siri Shortcuts Here
                Section {
                    self.style.fallback
                        .action(text: self.text.timeAgo(item.wrappedValue.lastPerformDate))
                        .label
                } header: {
                    self.style.sectionHeader
                        .action(text: self.text.lastPerformed)
                        .label
                }
            }
        } onNIL: {
            self.style.fallback
                      .action(text: self.text.notFound)
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
                self.errorResponder(DeleteRequestError.reminder(self.id))
            }
        )
    }
    
    private var kinds: [(Reminder.Kind, ActionLocalization)] {
        return Reminder.Kind.allCases.map { kind in
            switch kind {
            case .water:
                return (kind, self.text.kindWater)
            case .fertilize:
                return (kind, self.text.kindFertilize)
            case .trim:
                return (kind, self.text.kindTrim)
            case .mist:
                return (kind, self.text.kindMist)
            case .move:
                return (kind, self.text.kindMove)
            case .other:
                return (kind, self.text.kindOther)
            }
        }
    }
}
