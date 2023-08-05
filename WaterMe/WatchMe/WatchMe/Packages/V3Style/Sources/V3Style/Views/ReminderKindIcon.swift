//
//  Created by Jeffrey Bergier on 2023/07/10.
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

public struct ReminderKindIcon: ViewModifier {
    
    @Environment(\.colorScheme) private var scheme
    
    public func body(content: Content) -> some View {
        content
            .frame(width: 32, height: 32, alignment: .center) // TODO: Magic Numbers
            .background(Color.backgroundContent(self.scheme))
            .modifier(CircleModifierImage())
    }
}
