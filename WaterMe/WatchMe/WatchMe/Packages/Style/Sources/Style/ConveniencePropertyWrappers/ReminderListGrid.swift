//
//  Created by Jeffrey Bergier on 2022/02/07.
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

extension EnvironmentValues {
    public var sectionNumber: Int {
        get { self[SectionNumber.self] }
        set { self[SectionNumber.self] = newValue }
    }
}

public struct SectionNumber: EnvironmentKey {
    public static let defaultValue: Int = -1
}

@propertyWrapper
public struct ReminderListGrid: DynamicProperty, ConveniencePropertyWrapper {
    
    public struct Value {
        public var columns: [GridItem]
        public var header: HeaderModifier
    }
    
    @ThemeClass private var theme
    @SizeClass private var size
    private var themeOverride: Theme?
    private var sizeOverride: Size?
    
    public init(size: Size? = nil, theme: Theme? = nil) {
        self.sizeOverride = size
    }
    
    public var wrappedValue: Value {
        .init(
            columns: self.columns,
            header: .init(theme: self.themeOverride ?? self.theme,
                          size: self.sizeOverride ?? self.size.horizontal)
        )
    }
    
    private var columns: [GridItem] {
        switch self.sizeOverride ?? self.size.horizontal {
        case .small:
            return [
                GridItem(.flexible(minimum: 0, maximum: 320), spacing: 2, alignment: .top),
                GridItem(.flexible(minimum: 0, maximum: 320), spacing: 2, alignment: .top),
            ]
        case .medium:
            return [
                GridItem(.flexible(minimum: 0, maximum: 320), spacing: 0, alignment: .top),
                GridItem(.flexible(minimum: 0, maximum: 320), spacing: 0, alignment: .top),
            ]
        case .large:
            return [
                GridItem(.flexible(minimum: 0, maximum: 320), spacing: 0, alignment: .top),
                GridItem(.flexible(minimum: 0, maximum: 320), spacing: 0, alignment: .top),
                GridItem(.flexible(minimum: 0, maximum: 320), spacing: 0, alignment: .top),
                GridItem(.flexible(minimum: 0, maximum: 320), spacing: 0, alignment: .top),
            ]
        }
    }
}
