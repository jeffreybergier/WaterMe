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
        public var reminderKind:    ActionLocalization
        
        public init(vesselIconImage: JSBImage? = nil,
                    vesselIconEmoji: String? = nil,
                    reminderKind:    ActionLocalization)
        {
            self.vesselIconImage = vesselIconImage
            self.vesselIconEmoji = vesselIconEmoji
            self.reminderKind    = reminderKind
        }
    }
    
    public struct Value {
        internal var kindIcon:    some ActionStyle = ActionStyleImp(labelStyle: .iconOnly, outerModifier: ReminderKindIcon())
        public var button:        some ActionStyle = ActionStyleDefault
        public var buttonToolbar: some ActionStyle = ActionStyleImp(labelStyle: .titleAndIcon)

        internal init() { }
        
        public func icon(image: JSBImage, subtitle: LocalizedString) -> some View {
            VStack {
                Image(jsbImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Text(subtitle)
                    .lineLimit(2)
                    .font(.title3)
            }
        }
        
        @ViewBuilder public func threeUpIcon(_ request0: IconRequest?,
                                             _ request1: IconRequest?,
                                             _ request2: IconRequest?,
                                             _ extra:    Int?)
                                             -> some View
        {
            let total: Int = (request0 == nil ? 0 : 1) 
                           + (request1 == nil ? 0 : 1)
                           + (request2 == nil ? 0 : 1)
                           + (extra == nil ? 0 : 1)
            VStack(spacing: 0) {
                HStack {
                    if let request0 {
                        self.icon(request: request0, total: total)
                    }
                    if let request1 {
                        self.icon(request: request1, total: total)
                    }
                }
                HStack {
                    if let request2 {
                        self.icon(request: request2, total: total)
                    }
                    if let extra {
                        self.icon(extra: extra)
                    }
                }
            }
        }
        
        private func emojiFont(for total: Int) -> Font {
            switch total {
            case 1: return .emojiLargeExtra
            case 2: return .emojiLarge
            case 3: return .emojiMedium
            case 4: return .emojiSmall
            default: assertionFailure(); return .emojiSmall;
            }
        }
        
        private func icon(request: IconRequest, total: Int) -> some View {
            ZStack(alignment: .bottomTrailing) {
                VesselIcon(
                    image: request.vesselIconImage,
                    emoji: request.vesselIconEmoji
                )
                .modifier(FontModifier(self.emojiFont(for: total)))
                self.kindIcon
                    .action(text: request.reminderKind)
                    .label
            }
            .aspectRatio(contentMode: .fit)
        }
        
        private func icon(extra: Int) -> some View {
            ZStack {
                Color.clear
                Text("+" + String(describing: extra))
                    .font(.emojiExtra)
            }
            .aspectRatio(contentMode: .fit)
            .modifier(CircleModifierEmoji())
        }
    }
    
    public init() {}
    
    public var wrappedValue: Value {
        Value()
    }
}
