//
//  Created by Jeffrey Bergier on 2022/11/06.
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
import V3Localize
import V3Style

extension ReminderGrid {
    internal struct Cell: View {
        
        @V3Style.ReminderGrid private var style
        @V3Localize.ReminderGrid private var text

        @VesselQuery private var vesselQuery
        @ReminderQuery private var reminderQuery
        
        private let id: Reminder.Identifier
        private let action: () -> Void
        
        internal init(_ id: Reminder.Identifier,
                      action: @escaping () -> Void)
        {
            self.id = id
            self.action = action
        }
        
        internal var body: some View {
            self.reminderQuery.data.view(self.vesselQuery.data)
            { reminder, vessel in
                Button(action: self.action) {
                    VStack {
                        self.style.icon(image: vessel.icon?.imageValue,
                                        emoji: vessel.icon?.stringValue)
                        JSBText("My Plant", text: vessel.displayName)
                            .modifier(self.style.displayName)
                        self.kind(reminder.kind)
                            .modifier(self.style.kind)
                    }
                }
                .modifier(self.style.button)
            } onNIL: {
                self.style.fallback
                          .action(text: self.text.itemNotFound)
                          .label
                          .preference(key: isFallbackKey.self, value: true)
            }
            .onChange(of: self.id, initial: true) { _, newValue in
                self.reminderQuery.identifier = newValue
            }
            .onChange(of: self.reminderQuery.data?.vesselID, initial: true) { _, newValue in
                self.vesselQuery.identifier = newValue
            }
        }
        
        @ViewBuilder private func kind(_ kind: Reminder.Kind) -> some View {
            switch kind {
            case .water:
                Text(self.text.kindWater)
            case .fertilize:
                Text(self.text.kindFertilize)
            case .mist:
                Text(self.text.kindMist)
            case .trim:
                Text(self.text.kindTrim)
            case .move:
                Text(self.text.kindMove)
            case .other:
                Text(self.text.kindOther)
            }
        }
    }
}
