//
//  Created by Jeffrey Bergier on 2022/11/23.
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

internal struct ActionSubtitleModifier: ViewModifier {
    
    private let subtitle: LocalizedString
    
    internal init(subtitle: LocalizedString) {
        self.subtitle = subtitle
    }
    
    internal func body(content: Content) -> some View {
        VStack(alignment: .leading) {
            content
                .font(Font.normal)
            Text(self.subtitle)
                .font(Font.small)
        }
    }
}
