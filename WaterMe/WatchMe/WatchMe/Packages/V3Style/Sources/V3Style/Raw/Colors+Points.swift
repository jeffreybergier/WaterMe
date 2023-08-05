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
    internal static let emojiPickerSmall  = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
}

extension TimeInterval {
    internal static let syncIndicatorTimer: TimeInterval = 3
}

extension Font {
    internal static let prominent: Font   = .headline
    internal static let normal: Font      = .body
    internal static let small: Font       = .caption
    internal static let emojiSmall: Font  = .custom("Helvetica", size: 36, relativeTo: .title3)
    internal static let emojiMedium: Font = .custom("Helvetica", size: 47, relativeTo: .title3)
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
    internal static func tintApplication(_ scheme: ColorScheme) -> Color {
        scheme.isLight ? Color(red: 200 / 255.0, green: 129 / 255.0, blue: 242 / 255.0)
                       : Color(red: 192 / 255.0, green: 85 / 255.0, blue: 255 / 255.0)
    }
    internal static func tintApplicationAccessible(_ scheme: ColorScheme) -> Color {
        scheme.isLight ? Color(red: 97 / 255.0, green: 46 / 255.0, blue: 128 / 255.0)
                       : Color(red: 240 / 255.0, green: 216 / 255.0, blue: 255 / 255.0)
    }
    internal static func tintReminderLate(_ scheme: ColorScheme) -> Color {
        scheme.isLight ? Color(red: 221 / 255.0, green: 158 / 255.0, blue: 95 / 255.0)
                       : Color(red: 255 / 255.0, green: 163 / 255.0, blue: 72 / 255.0)
    }
    internal static func tintReminderToday(_ scheme: ColorScheme) -> Color {
        tintReminderTomorrow(scheme)
    }
    internal static func tintReminderTomorrow(_ scheme: ColorScheme) -> Color {
        scheme.isLight ? Color(red: 26 / 255.0, green: 188 / 255.0, blue: 156 / 255.0)
                       : Color(red: 8 / 255.0, green: 228 / 255.0, blue: 185 / 255.0)
    }
    internal static func tintReminderThisWeek(_ scheme: ColorScheme) -> Color {
        tintReminderLater(scheme)
    }
    internal static func tintReminderLater(_ scheme: ColorScheme) -> Color {
        tintApplication(scheme)
    }
    internal static func tintReminderDisabled(_ scheme: ColorScheme) -> Color {
        scheme.isLight ? Color(red: 0.6, green: 0.6, blue: 0.7)
                       : Color(red: 0.6, green: 0.6, blue: 0.7)
    }
    internal static func backgroundContent(_ scheme: ColorScheme) -> Color {
        scheme.isLight ? Color(red: 1.0, green: 1.0, blue: 1.0)
                       : Color(red: 0.0, green: 0.0, blue: 0.0)
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
