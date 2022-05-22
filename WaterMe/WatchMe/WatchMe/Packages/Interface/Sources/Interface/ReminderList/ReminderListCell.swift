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
import Umbrella
import Style
import Localize

extension ReminderList.Grid {
    internal struct Cell: View {
        
        private var reminder: Reminder
        @VesselEditQuery private var vessel: Vessel
        @Localize.ReminderList private var text
        @Style.ReminderListGridCell private var style
        
        internal init(reminder: Reminder) {
            self.reminder = reminder
            _vessel = VesselEditQuery(reminder)
        }
        
        internal var body: some View {
            VStack {
                ZStack(alignment: .bottomTrailing) {
                    VesselIcon(icon: self.vessel.icon)
                    ReminderKind(kind: self.reminder.kind)
                }
                JSBText(self.text(\.subsectionPlaceholderName),
                        text: self.vessel.displayName)
                    .modifier(self.style.vesselDisplayNameText)
                Text(self._text.subsectionDataKind(self.reminder.kind))
                    .modifier(self.style.reminderKindText)
            }
        }
    }
}
