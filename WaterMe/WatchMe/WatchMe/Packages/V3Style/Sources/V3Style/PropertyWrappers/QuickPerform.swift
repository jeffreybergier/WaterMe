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

@MainActor
@propertyWrapper
public struct QuickPerform: DynamicProperty {
    
    public struct Request {
        internal let request0: Description?
        internal let request1: Description?
        internal let request2: Description?
        internal let extra:    Int?
        internal let total:  Int
        public init(_ request0: Description?,
                    _ request1: Description?,
                    _ request2: Description?,
                    _ extra:    Int?)
        {
            self.request0 = request0
            self.request1 = request1
            self.request2 = request2
            self.extra    = extra
            self.total    = (request0 == nil ? 0 : 1)
                          + (request1 == nil ? 0 : 1)
                          + (request2 == nil ? 0 : 1)
                          + (extra == nil ? 0 : 1)
        }
        
        public struct Description {
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
    }
    
    @MainActor
    public struct Value {
        
        internal var kindIcon:    some ActionStyle = ActionStyleImp(labelStyle: .iconOnly, outerModifier: ReminderKindIcon())
        public var button:        some ActionStyle = ActionStyleDefault
        public var buttonToolbar: some ActionStyle = ActionStyleImp(labelStyle: .titleAndIcon)
        
        public var request: Request

        internal init(request: Request) {
            self.request = request
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
        
        @ViewBuilder public var threeUpIcon: some View {
            Grid {
                GridRow {
                    if let request0 = self.request.request0 {
                        self.icon(request: request0)
                    }
                    if let request1 = self.request.request1 {
                        self.icon(request: request1)
                    }
                }
                GridRow {
                    if let request2 = self.request.request2 {
                        self.icon(request: request2)
                    }
                    if let extra = self.request.extra {
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
        
        private func kindSize(for total: Int) -> CGSize {
            switch total {
            case 1: return .init(width: .sizeKindIconLargeExtra,
                                 height: .sizeKindIconLargeExtra)
            case 2: return .init(width: .sizeKindIconLarge, 
                                 height: .sizeKindIconLarge)
            case 3: return .init(width: .sizeKindIconMedium, 
                                 height: .sizeKindIconMedium)
            case 4: return .init(width: .sizeKindIconSmall, 
                                 height: .sizeKindIconSmall)
            default:
                assertionFailure()
                return .init(width: .sizeKindIconSmall, 
                             height: .sizeKindIconSmall)
            }
        }
        
        private func icon(request: Request.Description) -> some View {
            ZStack(alignment: .bottomTrailing) {
                VesselIcon(
                    image: request.vesselIconImage,
                    emoji: request.vesselIconEmoji
                )
                .modifier(FontModifier(self.emojiFont(for: self.request.total)))
                self.kindIcon
                    .action(text: request.reminderKind)
                    .label
                    .frame(self.kindSize(for: self.request.total))
            }
            .aspectRatio(contentMode: .fit)
        }
        
        private func icon(extra: Int) -> some View {
            Text("+" + String(describing: extra))
                .font(.emojiExtra)
                .aspectRatio(contentMode: .fit)
                .padding()
                .modifier(CircleModifierEmoji())
        }
    }
    
    @State private var request = Request(nil, nil, nil, nil)
    
    public init() {}
    
    public var wrappedValue: Value {
        get { Value(request:self.request) }
        nonmutating set { self.$request.wrappedValue = newValue.request }
    }
}

fileprivate extension View {
    func frame(_ size: CGSize, alignment: Alignment = .center) -> some View {
        self.frame(width: size.width, height: size.height, alignment: alignment)
    }
}
