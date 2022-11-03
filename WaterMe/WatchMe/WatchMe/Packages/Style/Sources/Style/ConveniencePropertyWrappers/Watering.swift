//
//  Created by Jeffrey Bergier on 2022/02/12.
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

@propertyWrapper
public struct Watering: DynamicProperty, ConveniencePropertyWrapper {

    public struct Value {
        public var verticalSize: Size
    }

    @ThemeClass private var theme
    @SizeClass private var size
    private var sizeOverride: Size?
    private var themeOverride: Theme?

    public init(size: Size? = nil, theme: Theme? = nil) {
        self.sizeOverride = size
        self.themeOverride = theme
    }

    public var wrappedValue: Value {
        .init(verticalSize: self.size.vertical)
    }
}
