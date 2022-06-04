//
//  Created by Jeffrey Bergier on 2022/06/04.
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

import Settings
import Umbrella

extension ReminderHours {
    internal var localized: LocalizationKey {
        switch self {
        case .hour4:
            return Label.time4
        case .hour5:
            return Label.time5
        case .hour6:
            return Label.time6
        case .hour7:
            return Label.time7
        case .hour8:
            return Label.time8
        case .hour9:
            return Label.time9
        case .hour10:
            return Label.time10
        case .hour11:
            return Label.time11
        case .hour12:
            return Label.time12
        case .hour13:
            return Label.time13
        case .hour14:
            return Label.time14
        case .hour15:
            return Label.time15
        case .hour16:
            return Label.time16
        case .hour17:
            return Label.time17
        case .hour18:
            return Label.time18
        case .hour19:
            return Label.time19
        case .hour20:
            return Label.time20
        case .hour21:
            return Label.time21
        case .hour22:
            return Label.time22
        case .hour23:
            return Label.time23
        }
    }
}
