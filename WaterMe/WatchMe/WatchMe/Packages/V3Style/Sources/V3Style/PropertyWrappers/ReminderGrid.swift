//
//  Created by Jeffrey Bergier on 2022/11/13.
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

@propertyWrapper
public struct ReminderGrid: DynamicProperty {
    
    public struct Value {
        public var icon:        some ViewModifier = ReminderGridCellModifier(.icon)
        public var kind:        some ViewModifier = ReminderGridCellModifier(.smallText)
        public var button:      some ViewModifier = ReminderGridCellModifier(.button)
        public var displayName: some ViewModifier = ReminderGridCellModifier(.bigText)
        public var fallback:    some ActionStyle = ActionStyleFakeDisabled
        
        // TODO: Make number of columns sensitive to size class
        public func grid(@ViewBuilder content: () -> some View) -> some View {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                    content()
                }
            }
        }
    }
    
    public init() {}
    
    public var wrappedValue: Value {
        Value()
    }
}
