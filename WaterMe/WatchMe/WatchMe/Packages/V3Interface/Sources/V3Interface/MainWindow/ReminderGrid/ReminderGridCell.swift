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
        
        @Nav private var nav
        @V3Style.ReminderGrid private var style
        @V3Localize.ReminderGrid private var text

        @VesselQuery private var vessel
        @ReminderQuery private var reminder
        
        private let id: Reminder.Identifier
        
        internal init(_ id: Reminder.Identifier) {
            self.id = id
        }
        
        internal var body: some View {
            self.reminder.view(self.vessel) { reminder, vessel in
                Button {
                    self.nav.stack.view(reminder.id)
                } label: {
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
            .onLoadChange(of: self.id) {
                _reminder.setIdentifier($0)
            }
            .onLoadChange(of: self.reminder?.vesselID) {
                _vessel.setIdentifier($0)
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
