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
import Umbrella

internal struct ReminderList: View {
    
    @Nav private var nav
    @ReminderListQuery private var sections
    @EnvironmentObject private var controller: AnyController
    @EnvironmentObject private var errorQ: ErrorQueue
    
    internal var body: some View {
        NavigationView {
            Grid(sections: self.sections) { item in
                self.nav.state = .listMenu(.init(item.id, item.vesselID!))
            }
            .navigationTitle("WaterMe")
            .toolbar {
                Button("Add") {
                    switch self.controller.newVessel() {
                    case .success(let id):
                        self.nav.state = .listVesselEdit(.init(id))
                    case .failure(let error):
                        self.errorQ.value.append(error)
                    }
                }
            }
        }
    }
}
