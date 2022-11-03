//
//  Created by Jeffrey Bergier on 2022/02/18.
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
import Umbrella

extension Model.Reminder.Section.Kind {
    internal var localized: LocalizationKey {
        switch self {
        case .late:
            return Label.late
        case .today:
            return Label.today
        case .tomorrow:
            return Label.tomorrow
        case .thisWeek:
            return Label.thisWeek
        case .later:
            return Label.later
        case .disabled:
            return Label.paused
        }
    }
}
