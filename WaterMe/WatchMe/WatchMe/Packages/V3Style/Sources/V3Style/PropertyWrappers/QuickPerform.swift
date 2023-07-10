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
    
    public struct IconRequest {
        public var vesselIconImage: JSBImage?
        public var vesselIconEmoji: String?
        public var reminderKind: ActionLocalization
        public init(vesselIconImage: JSBImage? = nil,
                    vesselIconEmoji: String? = nil,
                    reminderKind: ActionLocalization)
        {
            self.vesselIconImage = vesselIconImage
            self.vesselIconEmoji = vesselIconEmoji
            self.reminderKind = reminderKind
        }
    }
    
    public struct Value {
        internal var kindIcon: some ActionStyle = ActionStyleImp(labelStyle: .iconOnly, outerModifier: ReminderKindIcon())
        public var button:     some ActionStyle = ActionStyleDefault
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
        
        public func icon(request: IconRequest) -> some View {
            ZStack(alignment: .bottomTrailing) {
                VesselIcon(image: request.vesselIconImage,
                           emoji: request.vesselIconEmoji)
                    .modifier(FontModifier(.emojiSmall))
                self.kindIcon
                    .action(text: request.reminderKind)
                    .label
            }
            .modifier(FallbackAlphaModifier())

        }
    }
    
    @Environment(\.colorScheme) private var scheme
    
    public init() {}
    
    public var wrappedValue: Value {
        Value(scheme: self.scheme)
    }
}
