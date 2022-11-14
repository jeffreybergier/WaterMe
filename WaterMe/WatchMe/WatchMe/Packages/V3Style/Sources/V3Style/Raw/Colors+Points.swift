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

extension GridItem {
    internal static let reminderGridSmall = [GridItem(.flexible()), GridItem(.flexible())]
}

extension TimeInterval {
    internal static let syncIndicatorTimer: TimeInterval = 3
}

extension Font {
    internal static let prominent: Font = .headline
    internal static let normal: Font = .body
    internal static let small: Font = .caption
    internal static let emojiSmall: Font = .custom("Helvetica", size: 36, relativeTo: .title3)
}

extension CGFloat {
    internal static let thumbnailSmall: CGFloat = 64
    internal static let thumbnailMedium: CGFloat = 128
    internal static let thumbnailLarge: CGFloat = 280
}

extension Color {
    internal static func grayLight(_ scheme: ColorScheme) -> Color {
        scheme.isLight ? Color(red: 0.9, green: 0.9, blue: 0.9)
                       : Color(red: 0.25, green: 0.25, blue: 0.25)
    }
    internal static func grayMedium(_ scheme: ColorScheme) -> Color {
        scheme.isLight ? Color(red: 0.8, green: 0.8, blue: 0.8)
                       : Color(red: 0.35, green: 0.35, blue: 0.35)
    }
    internal static func grayDark(_ scheme: ColorScheme) -> Color {
        scheme.isLight ? Color(red: 0.7, green: 0.7, blue: 0.7)
                       : Color(red: 0.25, green: 0.25, blue: 0.25)
    }
    internal static func text(_ scheme: ColorScheme) -> Color {
        scheme.isLight ? Color.black
                       : Color.white
    }
}

extension ColorScheme {
    fileprivate var isLight: Bool {
        switch self {
        case .dark:
            return false
        case .light:
            fallthrough
        @unknown default:
            return true
        }
    }
}
