//
//  Created by Jeffrey Bergier on 2023/10/22.
//  Copyright © 2023 Saturday Apps.
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

@propertyWrapper
public struct FeatureFlags: DynamicProperty {
    public struct Value: OptionSet, Sendable {
        public let rawValue: UInt
        public static let editReminder    = Value(rawValue: 1 << 0)
        public static let addReminder     = Value(rawValue: 1 << 1)
        public static let deleteReminder  = Value(rawValue: 1 << 2)
        public static let performReminder = Value(rawValue: 1 << 3)
        public static let editVessel      = Value(rawValue: 1 << 4)
        public static let addVessel       = Value(rawValue: 1 << 5)
        public static let deleteVessel    = Value(rawValue: 1 << 6)
        static let all:   Value = [.editReminder, .addReminder, .deleteReminder, .performReminder, .editVessel, .addVessel, .deleteVessel]
        static let watch: Value = [.deleteReminder, .performReminder, .deleteVessel]
        static let none:  Value = []
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }
    public var wrappedValue: Value {
        get { .watch }
    }
    public init() {}
}
