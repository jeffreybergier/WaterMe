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

public struct Interface: View {

    @Nav private var nav
    @StateObject private var controller = NewController(of: .local)!
    
    public init() {}

    public var body: some View {
        NavigationView {
            self.render()
        }
        .environmentObject(self.controller)
        .environment(\.managedObjectContext, self.controller.__ENVONLY__managedObjectContext)
    }

    @ViewBuilder private func render() -> some View {
        // TODO: Summary, Settings, Error
        ReminderList()
            .modifier(ReminderList.Menu())
            .modifier(ListToReminderEdit())
            .modifier(ListToVesselEdit())
            .modifier(ListToWatering())
    }
}

extension Interface {
    private struct ListToReminderEdit: ViewModifier {
        @Nav private var nav
        @EnvironmentObject private var controller: AnyController
        func body(content: Content) -> some View {
            content
                .sheet(item: self.$nav.isReminder) { uuid in
                    ReminderEdit(id: uuid, controller: self.controller)
                }
        }
    }

    private struct ListToVesselEdit: ViewModifier {
        @Nav private var nav
        @EnvironmentObject private var controller: AnyController
        func body(content: Content) -> some View {
            content
                .sheet(item: self.$nav.isVessel) { input in
                    VesselEdit(id: input.id, controller: self.controller)
                }
        }
    }

    private struct ListToWatering: ViewModifier {
        @Nav private var nav
        @EnvironmentObject private var controller: AnyController
        func body(content: Content) -> some View {
            content
                .sheet(isPresented: self.$nav.isWatering) {
                    Watering()
                }
        }
    }
}

