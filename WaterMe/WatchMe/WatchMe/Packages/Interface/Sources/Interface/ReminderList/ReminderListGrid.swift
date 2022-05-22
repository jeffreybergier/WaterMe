//
//  Created by Jeffrey Bergier on 2022/01/09.
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
import Style
import Nav
import Localize

extension ReminderList {
    internal struct Grid: View {
        
        let sections: [Reminder.Section]
        let onTap: (Reminder) -> Void
        @NavReminderList private var nav
        @Style.ReminderListGrid private var style
        @Localize.ReminderList private var text
        
        internal var body: some View {
            ScrollView {
                LazyVGrid(columns: self.style.columns,
                          pinnedViews: .sectionHeaders)
                {
                    ForEach(self.sections) { section in
                        if section.data.isEmpty == false {
                            self.section(for: section)
                        }
                    }
                }
            }
        }
        
        @ViewBuilder private func section(for section: Reminder.Section) -> some View {
            Section {
                ForEach(section.data) { item in
                    self.row(for: item)
                }
            } header: {
                Text(self._text.sectionHeader(section.kind))
                    .modifier(self.style.header)
                    .environment(\.sectionNumber, section.kind.rawValue)
            }
        }
        
        @ViewBuilder private func row(for item: Reminder) -> some View {
            Button {
                self.onTap(item)
            } label: {
                Cell(reminder: item)
                    .xp_popover(item: self.$nav.isSummary) { input in
                        ReminderSummary(rID: input.reminderID,
                                        vID: input.vesselID)
                            .modifier(ReminderSummary.Presentation())
                    }
            }
        }
    }
}
