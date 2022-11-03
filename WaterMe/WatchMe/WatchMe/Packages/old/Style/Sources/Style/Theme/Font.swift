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

internal typealias SizeFont = CompleteDictionary<Size, Font>
internal typealias ButtonFont = CompleteDictionary<ButtonModifier.Action, Font>

internal enum Fonts {
    internal static let sectionTitle: Font             = Raw.subheadline
    internal static let subsectionTitle: Font          = Raw.callout
    internal static let subsectionData: Font           = Raw.body
    internal static let reminderListItemTitle: Font    = Raw.headline
    internal static let reminderListItemSubtitle: Font = Raw.subheadline
    internal static let vesselIconEmoji: SizeFont      = [.small: Raw.emojiSmall,
                                                          .medium: Raw.emojiMedium,
                                                          .large: Raw.emojiLarge,]
    internal static let reminderListGridHeader: Font = Raw.headline
    internal static let button: ButtonFont = [
        .primary: Raw.headline,
        .normal: Raw.body,
        .cancel: Raw.title3,
        .destructive: Raw.headline,
    ]
}

extension Fonts {
    internal enum Raw {
        internal static let subheadline: Font = .subheadline
        internal static let callout: Font = .callout
        internal static let body: Font = .body
        internal static let headline: Font = .headline
        internal static let title3: Font = .title3
        internal static let emojiSmall: Font = .custom("Helvetica", size: 48)
        internal static let emojiMedium: Font = .custom("Helvetica", size: 60)
        internal static let emojiLarge: Font = .custom("Helvetica", size: 72)
    }
}
