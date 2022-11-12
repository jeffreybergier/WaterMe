//
//  Created by Jeffrey Bergier on 2022/11/12.
//
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
import V3Model
import V3Datum

internal struct ReminderSummary: View {
    
    @Nav private var nav
    @ReminderQuery private var reminder
    private let id: Reminder.Identifier
    
    internal init(_ id: Reminder.Identifier) {
        self.id = id
    }
    
    internal var body: some View {
        self.reminder.view { item in
            List {
                Button {
                    // TODO: Mark as Done
                } label: {
                    Text("Mark Reminder as Done")
                }
                Button {
                    self.nav.edit(item.id)
                } label: {
                    Text("Edit Reminder")
                }
                Button {
                    item.vesselID.map { self.nav.edit($0) }
                } label: {
                    Text("Edit Plant")
                }
            }
        } onNIL: {
            Text("Loading...")
        }
        .navigationTitle("Summary")
        .onLoadChange(of: self.id) {
            _reminder.setIdentifier($0)
        }
    }
}
