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

import Model
import Foundation

extension Reminder.Section.Kind {
    internal var dateInterval: DateInterval {
        switch self {
        case .late:
            return ReminderDateCalculator.late()
        case .today:
            return ReminderDateCalculator.today()
        case .tomorrow:
            return ReminderDateCalculator.tomorrow()
        case .thisWeek:
            return ReminderDateCalculator.thisWeek()
        case .later:
            return ReminderDateCalculator.later()
        case .disabled:
            fatalError("DISABLED does not have a date range")
        }
    }
}
