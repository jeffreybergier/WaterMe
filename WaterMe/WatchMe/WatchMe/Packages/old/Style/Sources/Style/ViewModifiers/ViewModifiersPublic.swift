//
//  Created by Jeffrey Bergier on 2022/02/13.
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

public struct CenterModifier: ViewModifier {
    public init() {}
    public func body(content: Content) -> some View {
        HStack(spacing: 0) {
            Spacer()
            content
            Spacer()
        }
    }
}

public struct ButtonModifier: ViewModifier {

    public enum Action: CaseIterable {
        case primary, normal, cancel, destructive
    }

    private var action: Action
    @ThemeClass private var theme

    public init(role: Action) {
        self.action = role
    }

    private var font: ButtonFont = Fonts.button
    private var color: ButtonColor = Colors.button

    public func body(content: Content) -> some View {
        content
            .font(self.font[self.action])
            .foregroundColor(self.color[self.action][self.theme])
            .modifier(CenterModifier())
    }
}
