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

internal struct ButtonBorderShapeModifier: ViewModifier {
    private let shape: ButtonBorderShape
    internal init(_ shape: ButtonBorderShape) {
        self.shape = shape
    }
    internal func body(content: Content) -> some View {
        content
            .buttonBorderShape(self.shape)
    }
}

internal struct FontModifier: ViewModifier {
    private let font: Font
    internal init(_ font: Font) {
        self.font = font
    }
    internal func body(content: Content) -> some View {
        content.font(self.font)
    }
}
