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
        public var backgroundTomorrow:     Color
        public var backgroundLateAndToday: Color

        internal init(scheme: ColorScheme) {
            self.backgroundTomorrow     = .tintReminderTomorrow(scheme)
            self.backgroundLateAndToday = .tintReminderLate(scheme)

        }
        
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
            if let request0, let request1, let request2, let extra {
                Grid {
                    GridRow {
                        self.icon(request: request0)
                        self.icon(request: request1)
                    }
                    GridRow {
                        self.icon(request: request2)
                        self.icon(extra: extra)
                    }
                }
            } else if let request0, let request1, let request2 {
                VStack {
                    HStack {
                        self.icon(request: request0)
                        self.icon(request: request1)
                    }
                    self.icon(request: request2)
                }
            } else if let request0, let request1 {
                HStack {
                    self.icon(request: request0)
                    self.icon(request: request1)
                }
            } else if let request0 {
                self.icon(request: request0)
            }
        }
        
        private func icon(request: IconRequest) -> some View {
            ZStack(alignment: .bottomTrailing) {
                VesselIcon(image: request.vesselIconImage,
                           emoji: request.vesselIconEmoji)
                    .modifier(FontModifier(.emojiSmall))
                    .padding([.trailing, .bottom], .paddingVesselKind)
                self.kindIcon
                    .action(text: request.reminderKind)
                    .label
            }
        }
        
        private func icon(extra: Int) -> some View {
            Text("+" + String(describing: extra))
                .font(.prominent)
                .frame(width: .sizeIconExtra,
                       height: .sizeIconExtra,
                       alignment: .center)
                .modifier(CircleModifierEmoji())
        }
    }
    
    @Environment(\.colorScheme) private var scheme
    
    public init() {}
    
    public var wrappedValue: Value {
        Value(scheme: self.scheme)
    }
}
