//
//  Created by Jeffrey Bergier on 2022/11/11.
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

extension ReminderGrid {
    internal struct Header: View {
        
        @V3Localize.ReminderGrid private var text
                
        private let section: Reminder.Section
        
        internal init(_ section: Reminder.Section) {
            self.section = section
        }
        
        @ViewBuilder internal var body: some View {
            switch self.section {
            case .late:     Text(self.text.sectionTitleLate)
            case .today:    Text(self.text.sectionTitleToday)
            case .tomorrow: Text(self.text.sectionTitleTomorrow)
            case .thisWeek: Text(self.text.sectionTitleThisWeek)
            case .later:    Text(self.text.sectionTitleLater)
            case .disabled: Text(self.text.sectionTitleDisabled)
            }
        }
    }
}
