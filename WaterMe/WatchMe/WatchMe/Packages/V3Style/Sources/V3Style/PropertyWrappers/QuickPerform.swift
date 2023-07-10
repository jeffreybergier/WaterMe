//
//  Created by Jeffrey Bergier on 2023/05/28.
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
public struct QuickPerform: DynamicProperty {
    
    public struct Value {
        public var button: some ActionStyle = ActionStyleDefault
        public var backgroundLate:     Color
        public var backgroundToday:    Color
        public var backgroundTomorrow: Color
        public var backgroundThisWeek: Color
        public var backgroundLater:    Color
        public var backgroundDisabled: Color

        
        internal init(scheme: ColorScheme) {
            self.backgroundLate     = .tintReminderLate(scheme)
            self.backgroundToday    = .tintReminderToday(scheme)
            self.backgroundTomorrow = .tintReminderTomorrow(scheme)
            self.backgroundThisWeek = .tintReminderThisWeek(scheme)
            self.backgroundLater    = .tintReminderLater(scheme)
            self.backgroundDisabled = .tintReminderDisabled(scheme)

        }
        
        public func icon(image: JSBImage?, emoji: String?) -> some View {
            VesselIcon(image: image, emoji: emoji)
                .modifier(FontModifier(.emojiSmall))
                .modifier(FallbackAlphaModifier())
        }
    }
    
    @Environment(\.colorScheme) private var scheme
    
    public init() {}
    
    public var wrappedValue: Value {
        Value(scheme: self.scheme)
    }
}
