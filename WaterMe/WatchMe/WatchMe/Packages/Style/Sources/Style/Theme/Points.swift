//
//  Created by Jeffrey Bergier on 2022/02/11.
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

internal typealias SizePoint = CompleteDictionary<Size, CGFloat>
internal typealias SizeInsets = CompleteDictionary<Size, EdgeInsets>
internal typealias SizePadding = CompleteDictionary<Size, (Edge.Set, CGFloat?)>

internal enum Points {
    internal static let vesselIconCircleRadius: SizePoint = [.small: 72,
                                                             .medium: 100,
                                                             .large: 130]
    internal static let vesselIconCircleStroke: SizePoint = [.small: 2,
                                                             .medium: 2,
                                                             .large: 2]
    internal static let reminderKindCircleRadius: SizePoint = [.small: 30,
                                                               .medium: 50,
                                                               .large: 60]
    internal static let reminderKindCircleStroke: SizePoint = [.small: 1,
                                                               .medium: 1,
                                                               .large: 1]
    internal static let reminderListGridHeaderAccentSize: SizePoint = [.small: 2,
                                                                       .medium: 3,
                                                                       .large: 3]
    internal static let reminderListGridHeaderCornerRadius: SizePoint = [.small: 8,
                                                                         .medium: 8,
                                                                         .large: 8]
    internal static let subsectionDataVerticalSpacing: SizePoint = [.small: 0,
                                                                    .medium: 4,
                                                                    .large: 4]
    internal static let reminderListGridHeaderPaddingInside: SizeInsets = [
        .small: EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12),
        .medium: EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12),
        .large: EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
    ]
    internal static let reminderListGridHeaderPaddingOutside: SizeInsets = [
        .small: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
        .medium: EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4),
        .large: EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
    ]
    internal static let sectionPaddingTop: SizePadding = [
        .small: ([], nil),
        .medium: ([.top], 6),
        .large: ([.top], 6)
    ]
    internal static let sectionPaddingBottom: SizePadding = [
        .small: ([], nil),
        .medium: ([.bottom], 6),
        .large: ([.bottom], 6)
    ]
    internal static let textEditorMinHeight: SizePoint = [.small: 8*1,
                                                          .medium: 8*30,
                                                          .large: 8*45]
    internal static let multilineLabelMaxHeight: SizePoint = [.small: 8*16,
                                                              .medium: 8*30,
                                                              .large: 8*45]
}
