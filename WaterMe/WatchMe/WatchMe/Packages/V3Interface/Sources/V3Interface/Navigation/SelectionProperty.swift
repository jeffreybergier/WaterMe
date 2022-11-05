//
//  Created by Jeffrey Bergier on 2022/08/23.
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

@propertyWrapper
internal struct Selection: DynamicProperty {
    
    internal struct Value: Codable {
        internal var vessel: Vessel.Selection.Element?
        internal var reminders: Reminder.Selection = []
    }
    
    @JSBSceneStorage("com.hipstapaper.selection") private var storage = Value()
    
    internal var wrappedValue: Value {
        get { self.storage }
        nonmutating set { self.storage = newValue }
    }
    
    internal var projectedValue: Binding<Value> {
        self.$storage
    }
}
