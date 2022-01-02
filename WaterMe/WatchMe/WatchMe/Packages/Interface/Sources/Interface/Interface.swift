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
import Nav

public struct Interface: View {

    @Nav private var nav
    @StateObject private var controller = NewController(of: .local)!
    
    public init() {}
    
    public var body: some View {
        self.render()
            .environmentObject(self.controller)
            .environment(\.managedObjectContext, self.controller.__ENVONLY__managedObjectContext)
    }
    
    @ViewBuilder private func render() -> some View {
        // TODO: Summary, Settings, Error
        ReminderList()
            .modifier(ListMenu())
            .modifier(ListWatering())
            .modifier(ListReminderEdit())
            .modifier(ListVesselEdit())
    }
}


extension Interface {
    internal struct ListMenu: ViewModifier {
        @Nav private var nav
        func body(content: Content) -> some View {
            content
                .confirmationDialog("// TODO: FixMe",
                                    isPresented: self.$nav.isListMenu,
                                    presenting: self.nav.isListMenuData)
            { input in
                Button   { self.nav.state = .listReminderEdit(.init(input.reminderID)) }
            label: { Text("Edit Reminder") }
                Button   { self.nav.state = .listVesselEdit(.init(input.vesselID)) }
            label: { Text("Edit Plant") }
                Button   { self.nav.state = .listSummary(.init(input.reminderID)) }
            label: { Text("View Summary") }
                Button { self.nav.state = .listWatering(.init([input.reminderID])) }
            label: { Text("Mark as Done") }
                Button { self.nav.reset() }
            label: { Text("Dismiss") }
            }
        }
    }
    private struct ListReminderEdit: ViewModifier {
        @Nav private var nav
        @EnvironmentObject private var controller: AnyController
        func body(content: Content) -> some View {
            content
                .sheet(item: self.$nav.isListReminderEdit) { input in
                    ReminderEdit(id: input.reminderID, controller: self.controller)
                }
        }
    }
    private struct ListVesselEdit: ViewModifier {
        @Nav private var nav
        @EnvironmentObject private var controller: AnyController
        func body(content: Content) -> some View {
            content
                .sheet(item: self.$nav.isListVesselEdit) { input in
                    VesselEdit(id: input.id, controller: self.controller)
                        .sheet(item: self.$nav.isListVesselEditReminderEdit) { input in
                            ReminderEdit(id: input.reminderID, controller: self.controller)
                        }
                }
        }
    }
    private struct ListWatering: ViewModifier {
        @Nav private var nav
        @EnvironmentObject private var controller: AnyController
        func body(content: Content) -> some View {
            content
                .sheet(item: self.$nav.isListWatering) { input in
                    Watering()
                }
        }
    }
}

