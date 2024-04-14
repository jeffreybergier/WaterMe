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

internal struct CircleModifierEmoji: ViewModifier {
    
    @Environment(\.tintColor) private var tintColor
    @Environment(\.colorScheme) private var scheme
    
    private let strokeColor: Color?
    private let strokeWidth: CGFloat
    
    internal init(strokeColor: Color? = nil,
                  strokeWidth: CGFloat = .strokeWidth)
    {
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
    }
    
    internal func body(content: Content) -> some View {
        content
            .background(Color.backgroundContent(self.scheme))
            .clipShape(Circle())
            .overlay(
                Circle().stroke(self.strokeColor ?? self.tintColor,
                                lineWidth: self.strokeWidth)
            )
    }
}

internal struct CircleModifierImage: ViewModifier {
    
    @Environment(\.tintColor) private var tintColor
    
    private let strokeColor: Color?
    private let strokeWidth: CGFloat
    
    internal init(strokeColor: Color? = nil,
                  strokeWidth: CGFloat = .strokeWidth)
    {
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
    }
    
    internal func body(content: Content) -> some View {
        content
            .clipShape(Circle())
            .overlay(
                Circle().stroke(self.strokeColor ?? self.tintColor,
                                lineWidth: self.strokeWidth)
            )
    }
}
