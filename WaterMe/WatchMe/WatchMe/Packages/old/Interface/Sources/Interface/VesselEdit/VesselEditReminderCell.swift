//
//  Created by Jeffrey Bergier on 2022/02/13.
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
import Datum
import Model
import Style
import Localize

extension VesselEdit {
    internal struct ReminderCell: View {

        @ReminderEditQuery private var reminder: Reminder
        // TODO: Make new style for this
        @Style.Form private var style
        @Localize.VesselEdit private var text
        @EnvironmentBundle<ImageBundle> private var image

        internal init(id: Reminder.アイディ) {
            _reminder = ReminderEditQuery(id: id)
        }

        @ViewBuilder internal var body: some View {
            // TODO: Replace magic number
            HStack(spacing: 8) {
                ReminderKind(kind: self.reminder.kind)
                VStack(alignment: .leading, spacing: self.style.subsectionDataVerticalSpacing) {
                    Text(self._text.subsectionDataKind(self.reminder.kind))
                    HStack {
                        Text(self.text(\.subsectionEvery))
                        Text(self._text.subsectionDataDayInterval(self.reminder.interval))
                    }
                }
                if self.reminder.isEnabled == false {
                    Spacer()
                    self.image.reminderPaused
                }
            }
            .modifier(self.style.subsectionData)
        }
    }
}
