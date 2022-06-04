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

extension Days {
    internal var localized: LocalizationKey {
        switch self {
        case .days7:
            return Label.days7
        case .days8:
            return Label.days8
        case .days9:
            return Label.days9
        case .days10:
            return Label.days10
        case .days11:
            return Label.days11
        case .days12:
            return Label.days12
        case .days13:
            return Label.days13
        case .days14:
            return Label.days14
        case .days15:
            return Label.days15
        case .days16:
            return Label.days16
        case .days17:
            return Label.days17
        case .days18:
            return Label.days18
        case .days19:
            return Label.days19
        case .days20:
            return Label.days20
        case .days21:
            return Label.days21
        }
    }
}
