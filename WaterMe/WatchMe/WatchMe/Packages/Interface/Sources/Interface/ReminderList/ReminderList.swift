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
import Nav
import Datum

internal struct ReminderList: View {
    
    @Nav private var nav
    @ReminderListQuery private var data
    @EnvironmentObject private var controller: AnyController
    
    internal var body: some View {
        NavigationView {
            VStack {
                List(self.data) { item in
                    Button {
                        self.nav.state = .listMenu(.init(item.id, item.wrappedValue.vesselID!))
                    } label: {
                        Cell(reminder: item, controller: self.controller)
                    }
                }
            }
            .navigationTitle("WaterMe")
            .toolbar {
                Button("Add") { /* TODO: FixMe */ }
            }
        }
    }
}
