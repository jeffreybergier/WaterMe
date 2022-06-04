//
//  Created by Jeffrey Bergier on 2022/05/29.
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

import CoreData
#if canImport(UIKit)
import UIKit
#endif

public enum ControllerKind: RawRepresentable {

    case local
    case sync
    case __testing_inMemory
    case __testing_withClass(NSPersistentContainer.Type)

    public var rawValue: Bool {
        switch self {
        case .local:
            return false
        case .sync:
            return true
        case .__testing_inMemory, .__testing_withClass:
            fatalError("RawValue unsupported while testing")
        }
    }

    public init(rawValue: Bool) {
        self = rawValue ? .sync : .local
    }
}

public enum DarkModeOverride: Int {
    case system = 0
    case forceLight = 1
    case forceDark = 2
}

internal var isDarkerSystemColorsEnabled: Bool {
    #if os(iOS) || os(tvOS)
    return UIAccessibility.isDarkerSystemColorsEnabled
    #else
    return false
    #endif
}
