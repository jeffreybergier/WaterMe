//
//  Created by Jeffrey Bergier on 2022/11/13.
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

/// Asset Catalog
internal enum Catalog: String {
    case camera          = "Camera"
    case plus            = "PlusIcon"
    case shovel          = "ReminderKindFertilize"
    case sprayer         = "ReminderKindMist"
    case wheelBarrow     = "ReminderKindMove"
    case boxOpen         = "ReminderKindOther"
    case scissors        = "ReminderKindTrim"
    case waterCan        = "ReminderKindWater"
    case present         = "TipJar"
    case appIcon         = "WaterMeIcon"
    
    internal var image: JSBImage {
        JSBImage.image(named: self.rawValue, in: Bundle.module)!
    }
}

/// SF Symbols
internal enum Symbol: String {
    case check           = "checkmark.circle.fill"
    case syncIdle        = "checkmark.icloud"
    case syncError       = "exclamationmark.icloud"
    case syncUnavailable = "xmark.icloud"
    case syncSyncing     = "arrow.clockwise.icloud"
    case ellipsis        = "ellipsis.circle"
    case noContent       = "circle.slash"
    case home            = "house"
    
    internal var view: Image {
        Image(systemName: self.rawValue)
    }
}
