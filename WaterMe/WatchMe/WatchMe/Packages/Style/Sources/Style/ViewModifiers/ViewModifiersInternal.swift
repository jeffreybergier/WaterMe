//
//  Created by Jeffrey Bergier on 2022/02/10.
//  Copyright © 2021 Saturday Apps.
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

public struct PaddingModifier: ViewModifier {
    
    internal var padding: SizePadding
    internal var size: Size
    
    public func body(content: Content) -> some View {
        content
            .padding(self.padding[self.size].0,
                     self.padding[self.size].1)
    }
    
}

public struct TextModifier: ViewModifier {
    
    internal var color: ThemeColor
    internal var font: Font
    internal var theme: Theme
    
    public func body(content: Content) -> some View {
        content
            .font(self.font)
            .foregroundColor(self.color[self.theme])
    }
}

public struct ColorModifier: ViewModifier {
    
    internal var tint: ThemeColor?
    internal var foreground: ThemeColor?
    internal var background: ThemeColor?
    internal var theme: Theme
    
    public func body(content: Content) -> some View {
        content
            .tint(self.tint?[self.theme])
            .foregroundColor(self.foreground?[self.theme])
            .background(self.background?[self.theme])
    }
}

public struct CircleModifier: ViewModifier {
    
    internal var radius: SizePoint
    internal var stroke: SizePoint
    internal var color: ThemeColor
    internal var theme: Theme
    internal var size: Size
    
    public func body(content: Content) -> some View {
        content
            .frame(width: self.radius[self.size],
                   height: self.radius[self.size],
                   alignment: .center)
            .clipShape(Circle())
            .overlay(
                Circle().stroke(self.color[self.theme],
                                lineWidth: self.stroke[self.size])
            )
    }
}

public struct HeaderModifier: ViewModifier {
    
    internal var theme: Theme
    internal var size: Size
    @Environment(\.sectionNumber) private var section
    
    public func body(content: Content) -> some View {
        ZStack(alignment: .bottomLeading) {
            XPVisualEffectView(
                fallback: Colors.reminderListGridHeaderFallback,
                theme: self.theme
            )
            content
                .padding(Points.reminderListGridHeaderPaddingInside[self.size])
                .font(Fonts.reminderListGridHeader)
                .foregroundColor(Colors.reminderListGridHeaderAccent[self.section]![self.theme])
            Colors.reminderListGridHeaderAccent[self.section]![self.theme]
                .frame(height: Points.reminderListGridHeaderAccentSize[self.size])
        }
        .clipShape(RoundedRectangle(cornerRadius: Points.reminderListGridHeaderCornerRadius[self.size]))
        .padding(Points.reminderListGridHeaderPaddingOutside[self.size])
    }
}

public struct PopoverSizeModifier: ViewModifier {
    
    internal var size: CGSize
    // TODO: HACK workaround where this was breaking display in WatchOS
    internal var _size: CGSize? {
        #if os(watchOS)
        return nil
        #else
        return self.size
        #endif
    }
    
    public func body(content: Content) -> some View {
        content
            .frame(minWidth: _size?.width, minHeight: _size?.height)
    }
}

public struct MinHeightModifier: ViewModifier {
    
    internal var size: Size
    internal var height: SizePoint
    
    public func body(content: Content) -> some View {
        content
            .frame(minHeight: self.height[self.size], alignment: .topLeading)
    }
}

public struct MaxHeightModifier: ViewModifier {
    
    internal var size: Size
    internal var height: SizePoint
    
    public func body(content: Content) -> some View {
        content
            .frame(maxHeight: self.height[self.size], alignment: .topLeading)
    }
}
