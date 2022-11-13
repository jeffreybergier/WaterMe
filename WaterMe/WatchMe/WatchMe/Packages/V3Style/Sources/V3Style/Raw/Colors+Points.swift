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

extension TimeInterval {
    internal static let syncIndicatorTimer: TimeInterval = 3
}

extension Font {
    internal static let prominent: Font = .headline
    internal static let normal: Font = .body
    internal static let small: Font = .caption
}

extension CGFloat {
    internal static let thumbnailSmall: CGFloat = 64
    internal static let thumbnailMedium: CGFloat = 128
    internal static let thumbnailLarge: CGFloat = 280
}

extension Color {
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
