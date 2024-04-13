//
//  Created by Jeffrey Bergier on 2024/02/25.
//  Copyright © 2024 Saturday Apps.
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

@propertyWrapper
public struct ShareList: DynamicProperty {
    
    public struct Value {
        public let title:         LocalizedString
        public let rowTitle:      ActionLocalization
        public let firstSyncWait: ActionLocalization

        internal init(_ b: Bundle) {
            self.title         = b.localized(key: Noun.libraries.rawValue)
            self.rowTitle      = Action.home.localized(b)
            self.firstSyncWait = Action.watch_syncInitialize.localized(b)
        }
    }
    
    @Environment(\.bundle) private var bundle
    
    public init() {}
    
    public var wrappedValue: Value {
        Value(self.bundle)
    }
}
