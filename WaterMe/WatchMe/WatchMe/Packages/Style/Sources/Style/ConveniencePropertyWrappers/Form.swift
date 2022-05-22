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
public struct Form: DynamicProperty, ConveniencePropertyWrapper {
    
    public struct Value {
        public var sectionTitle: TextModifier
        public var sectionPaddingTop: PaddingModifier
        public var sectionPaddingBottom: PaddingModifier
        public var subsectionTitle: TextModifier
        public var subsectionData: TextModifier
        public var subsectionDataVerticalSpacing: CGFloat
        public var popoverControl: PopoverSizeModifier
        public var textEditorMinHeight: MinHeightModifier
        public var multilineLabelMaxHeight: MaxHeightModifier
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
        Value(sectionTitle: TextModifier(color: Colors.text_sectionTitle,
                                         font: Fonts.sectionTitle,
                                         theme: self.themeOverride ?? self.theme),
              sectionPaddingTop: PaddingModifier(padding: Points.sectionPaddingTop,
                                                    size: self.sizeOverride ?? self.size.horizontal),
              sectionPaddingBottom: PaddingModifier(padding: Points.sectionPaddingBottom,
                                                       size: self.sizeOverride ?? self.size.horizontal),
              subsectionTitle: TextModifier(color: Colors.text_subsectionTitle,
                                            font: Fonts.subsectionTitle,
                                            theme: self.themeOverride ?? self.theme),
              subsectionData: TextModifier(color: Colors.text_subsectionData,
                                           font: Fonts.subsectionData,
                                           theme: self.themeOverride ?? self.theme),
              subsectionDataVerticalSpacing: Points.subsectionDataVerticalSpacing[self.size.horizontal],
              popoverControl: PopoverSizeModifier(size: CGSize(width: 320, height: 480)),
              textEditorMinHeight: MinHeightModifier(size: self.size.horizontal, height: Points.textEditorMinHeight),
              multilineLabelMaxHeight: MaxHeightModifier(size: self.size.horizontal, height: Points.multilineLabelMaxHeight))
    }
}
