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
        
        @Binding var nav: Nav
        
        func body(content: Content) -> some View {
            content
                .confirmationDialog("Hello",
                                    isPresented: Binding { true } set: { _ in self.nav = .list(.none) },
                                    titleVisibility: .hidden)
            {
                Button   { self.nav = .list(.reminder) }
                  label: { Text("Edit Reminder") }
                Button   { self.nav = .list(.plant) }
                  label: { Text("Edit Plant") }
                Button   { self.nav = .list(.summary) }
                  label: { Text("View Summary") }
                Button { self.nav = .list(.watering) }
                  label: { Text("Mark as Done") }
                Button { self.nav = .list(.none) }
                  label: { Text("Dismiss") }
            }
        }
    }
}
