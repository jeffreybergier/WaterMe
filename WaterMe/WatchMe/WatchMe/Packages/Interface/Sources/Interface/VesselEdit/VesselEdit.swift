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

internal struct VesselEdit: View {
    
    @ReminderVesselQuery var vessel: ReminderVessel
    
    internal init(vesselID: String, controller: AnyController) {
        _vessel = ReminderVesselQuery(uuid: vesselID, controller: controller)
    }
    
    internal var body: some View {
        VStack {
            Text(self.vessel.displayName ?? "-1")
        }
    }
}

extension VesselEdit {
    internal struct Pres: ViewModifier {
        let vesselID: String
        @Binding var nav: Nav
        @EnvironmentObject private var controller: AnyController
        func body(content: Content) -> some View {
            content
                .sheet(isPresented: Binding(get: { true }, set: { _ in self.nav = .list(.none) }), onDismiss: nil) {
                    VesselEdit(vesselID: self.vesselID, controller: self.controller)
                }
        }
    }
}
