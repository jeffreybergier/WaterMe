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
            self.onDataLoaded { reminder, vessel in
                Button {
                    self.nav.view(reminder.id)
                } label: {
                    VStack {
                        self.icon(vessel)
                            .modifier(self.style.iconCircle)
                        JSBText("My Plant", text: vessel.displayName)
                        self.kind(reminder.kind)
                    }
                }
            } onNIL: {
                self.style.fallback
                          .action(text: self.text.noContent)
                          .label
            }
            .onLoadChange(of: self.id) {
                _reminder.setIdentifier($0)
            }
            .onLoadChange(of: self.reminder?.vesselID) {
                _vessel.setIdentifier($0)
            }
        }
        
        @ViewBuilder private func onDataLoaded(
            @ViewBuilder content: (Reminder, Vessel) -> some View,
            @ViewBuilder onNIL: () -> some View
        ) -> some View {
            if let reminder, let vessel {
                content(reminder, vessel)
            } else {
                onNIL()
            }
        }
        
        @ViewBuilder private func icon(_ item: Vessel) -> some View {
            if let image = item.icon?.imageValue {
                Image(jsbImage: image)
            } else if let emoji = item.icon?.stringValue {
                Text(emoji)
            } else {
                Text("🌸")
            }
        }
        
        @ViewBuilder private func kind(_ kind: Reminder.Kind) -> some View {
            Text(String(describing: kind))
            /*
            switch kind {
            case .water:
            case .fertilize:
            case .mist:
            case .trim:
            case .other:
            }
             */
        }
    }
}
