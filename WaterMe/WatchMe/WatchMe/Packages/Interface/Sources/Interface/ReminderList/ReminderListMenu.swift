//
//  Created by Jeffrey Bergier on 2021/12/31.
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
import Datum

extension ReminderList {
    internal struct Menu: ViewModifier {
        
        @Nav private var nav

        func body(content: Content) -> some View {
            content
                .confirmationDialog("// TODO: FixMe",
                                    isPresented: self.$nav.isMenu,
                                    presenting: self.nav.isMenuData)
            { input in
                Button   { self.nav = .init(.list(.reminder(input.reminder))) }
                  label: { Text("Edit Reminder") }
                Button   { self.nav = .init(.list(.vessel(.init(input.vessel)))) }
                  label: { Text("Edit Plant") }
                Button   { self.nav = .init(.list(.summary(input.reminder))) }
                  label: { Text("View Summary") }
                Button { self.nav = .init(.list(.watering)) }
                  label: { Text("Mark as Done") }
                Button { self.nav = .init(.list(.none)) }
                  label: { Text("Dismiss") }
            }
        }
    }
}
