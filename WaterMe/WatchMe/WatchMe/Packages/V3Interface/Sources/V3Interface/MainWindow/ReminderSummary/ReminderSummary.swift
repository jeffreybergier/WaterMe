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

internal struct ReminderSummary: View {
    
    @Nav private var nav
    @Controller private var controller
    @ErrorStorage private var errors

    @V3Style.ReminderSummary private var style
    @V3Localize.ReminderSummary private var text
    
    @ReminderQuery private var reminder
    @VesselQuery private var vessel
    private let id: Reminder.Identifier
    
    internal init(_ id: Reminder.Identifier) {
        self.id = id
    }
    
    internal var body: some View {
        self.reminder.view(self.vessel) { reminder, vessel in
            List {
                Section {
                    self.style.button.action(text: self.text.markDone).button {
                        switch self.controller.appendNewPerformToReminders(with: [reminder.id]) {
                        case .success:
                            self.nav.stack.pop()
                        case .failure(let error):
                            self.errors.append(error)
                        }
                    }
                    self.style.button.action(text: self.text.editReminder).button {
                        self.nav.stack.edit(reminder.id)
                    }
                    self.style.button.action(text: self.text.editVessel).button {
                        self.nav.stack.edit(vessel.id)
                    }
                } header: {
                    self.style.sectionHeader
                              .action(text: self.text.actions)
                              .label
                }
                Section {
                    self.style.content(self.localized(kind: reminder.kind),
                                       label: self.text.kind)
                    self.style.content(self.text.due(date: reminder.nextPerformDate),
                                       label: self.text.nextPerformDate)
                    self.style.content(self.text.timeAgo(reminder.lastPerformDate),
                                       label: self.text.lastPerformDate)
                    self.style.content(self.text.interval(reminder.interval),
                                       label: self.text.interval)
                } header: {
                    self.style.sectionHeader
                              .action(text: self.text.reminder)
                              .label
                }
                Section {
                    self.style.icon(image: vessel.icon?.imageValue,
                                    emoji: vessel.icon?.stringValue)
                    self.style.name(vessel.displayName,
                                    fallback: self.text.myPlant)
                } header: {
                    self.style.sectionHeader
                              .action(text: self.text.plant)
                              .label
                }
            }
        } onNIL: {
            self.style.content
                      .action(text: self.text.itemNotFound)
                      .label
                      .preference(key: isFallbackKey.self, value: true)
        }
        .navigationTitle(self.text.title)
        .onLoadChange(of: self.id) {
            _reminder.setIdentifier($0)
        }
        .onLoadChange(of: self.reminder?.vesselID) {
            _vessel.setIdentifier($0)
        }
    }
    
    private func localized(kind: Reminder.Kind) -> ActionLocalization {
        switch kind {
        case .water:
            return self.text.kindWater
        case .fertilize:
            return self.text.kindFertilize
        case .trim:
            return self.text.kindTrim
        case .mist:
            return self.text.kindMist
        case .move:
            return self.text.kindMove
        case .other:
            return self.text.kindOther
        }
    }
}
