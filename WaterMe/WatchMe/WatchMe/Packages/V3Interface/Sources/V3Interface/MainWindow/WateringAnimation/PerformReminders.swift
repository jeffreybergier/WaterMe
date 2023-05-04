//
//  Created by Jeffrey Bergier on 2023/05/04.
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
import V3Nav
import V3Model
import V3Datum

internal struct PerformReminders: View {
    
    @Nav private var nav
    @Controller private var controller
    @ErrorStorage private var errors
    
    @State private var didAppearOnce = false    
    private let selection: Reminder.Selection
    
    internal init(_ selection: Reminder.Selection) {
        self.selection = selection
    }
    
    internal var body: some View {
        WateringAnimation { self.nav.stack.pop() }
            .ignoresSafeArea()
            .onAppear {
                guard self.didAppearOnce == false else { return }
                self.didAppearOnce = true
                let result = self.controller.appendNewPerformToReminders(with: self.selection)
                result.error.map(self.errors.append(_:))
            }
    }
}
