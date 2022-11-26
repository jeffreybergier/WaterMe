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
        public var kind:        some ViewModifier = FontModifier(.small)
        public var button:      some ViewModifier = ButtonBorderShapeModifier(.roundedRectangle)
        public var fallback:    some ActionStyle  = ActionStyleDefault
        public var displayName: some ViewModifier = Modifier2(FontModifier(.prominent),
                                                              FallbackFontModifier()) 
        public var columns:          [GridItem]   = GridItem.reminderGridSmall
        public func icon(image: JSBImage?, emoji: String?) -> some View {
            VesselIcon(image: image, emoji: emoji)
                .modifier(FontModifier(.emojiSmall))
                .modifier(FallbackAlphaModifier())
        }
    }
    
    public init() {}
    
    public var wrappedValue: Value {
        Value()
    }
}
