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

extension Model.ReminderKind {
    internal var localizedShort: LocalizationKey {
        switch self {
        case .water:
            return Label.waterShort
        case .fertilize:
            return Label.fertilizeShort
        case .trim:
            return Label.trimShort
        case .mist:
            return Label.mistShort
        case .move:
            return Label.moveShort
        case .other:
            return Label.other
        }
    }

    internal var localizedLong: LocalizationKey {
        switch self {
        case .water:
            return Label.waterLong
        case .fertilize:
            return Label.fertilizeLong
        case .trim:
            return Label.trimLong
        case .mist:
            return Label.mistLong
        case .move:
            return Label.moveLong
        case .other:
            return Label.other
        }
    }
}
