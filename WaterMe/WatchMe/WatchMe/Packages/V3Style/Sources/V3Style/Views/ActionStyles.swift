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

internal let ActionStyleDefault:       some ActionStyle = ActionStyleImp(outerModifier: FallbackFontModifier())
internal let ActionStyleSyncIndicator: some ActionStyle = ActionStyleImp(labelStyle: .iconOnly)

internal struct FallbackAlphaModifier: ViewModifier {
    
    @State private var isFallback = false
    
    internal func body(content: Content) -> some View {
        Group {
            if self.isFallback {
                content
                    .opacity(.opacityIsFallback)
            } else {
                content
            }
        }
        .onPreferenceChange(isFallbackKey.self) {
            self.isFallback = $0
        }
    }
}

// TODO: change back to internal
public struct FallbackFontModifier: ViewModifier {
    
    @State private var isFallback = false
    @Environment(\.colorScheme) private var scheme
    
    private let font: Font
    
    public init(font: Font = .body) {
        self.font = font
    }
    
    public func body(content: Content) -> some View {
        Group {
            if self.isFallback {
                content
                    .font(self.font.italic())
                    .tint(Color.grayDark(self.scheme))
                    .foregroundColor(Color.grayDark(self.scheme))
            } else {
                content
                    .font(self.font)
            }
        }
        .onPreferenceChange(isFallbackKey.self) {
            self.isFallback = $0
        }
    }
}

// TODO: change back to internal
internal struct SingleLineModifier: ViewModifier {
    internal func body(content: Content) -> some View {
        content.lineLimit(1, reservesSpace: true)
    }
}

// TODO: change back to internal
public struct Modifier2<M1: ViewModifier, M2: ViewModifier>: ViewModifier {
    
    private let m1: M1
    private let m2: M2
    
    internal init(_ m1: M1, _ m2: M2) {
        self.m1 = m1
        self.m2 = m2
    }
    
    public func body(content: Content) -> some View {
        content
            .modifier(self.m1)
            .modifier(self.m2)
    }
}

// TODO: change back to internal
public struct ButtonDestructiveSimulated: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .foregroundStyle(.red)
    }
}
