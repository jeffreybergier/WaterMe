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
import Umbrella

public struct Interface: View {

    @Nav private var nav
    @StateObject private var controller = NewController(of: .local)!
    @StateObject private var errorQ = StringQueue(["An Error"])
    
    public init() {
        Loggable.configure()
    }
    
    public var body: some View {
        self.render()
            .environmentObject(self.controller)
            .environmentObject(self.errorQ)
            .environment(\.managedObjectContext, self.controller.__ENVONLY__managedObjectContext)
            .onChange(of: self.errorQ.value.first) { error in
                self.nav.append(String(describing: error))
            }
            .onAppear {
                guard let error = self.errorQ.value.first else { return }
                self.nav.append(String(describing: error))
            }
    }
    
    @ViewBuilder private func render() -> some View {
        // TODO: Summary, Settings, Error
        ReminderList()
            .modifier(JSBAlert(item: self.$nav.isRootアListアError, titleKey: "Fuck off", actions: { error in
                Button("Kill Me", action: {})
                Button(error, action: {})
            }, message: { _ in Text("This is a message") }))
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
                .modifier(
                    JSBConfirmationDialog(item: self.$nav.isRootアListアMenu,
                                          titleKey: "// TODO: Fix Me")
                    { input in
                        Button   { self.nav.state = .rootアListアReminderEdit(.init(input.reminderID)) }
                          label: { Text("Edit Reminder") }
                        Button   { self.nav.state = .rootアListアVesselEdit(.init(input.vesselID)) }
                          label: { Text("Edit Plant") }
                        Button   { self.nav.state = .rootアListアSummary(.init(input.reminderID)) }
                          label: { Text("View Summary") }
                        Button   { self.nav.state = .rootアListアWatering(.init([input.reminderID])) }
                          label: { Text("Mark as Done") }
                        Button   { self.nav.reset() }
                          label: { Text("Dismiss") }
                    }
                )
        }
    }
    private struct ListReminderEdit: ViewModifier {
        @Nav private var nav
        @EnvironmentObject private var controller: AnyController
        func body(content: Content) -> some View {
            content
                .sheet(item: self.$nav.isRootアListアReminderEdit) { input in
                    ReminderEdit(id: input.reminderID, controller: self.controller)
                }
        }
    }
    private struct ListVesselEdit: ViewModifier {
        @Nav private var nav
        @EnvironmentObject private var controller: AnyController
        func body(content: Content) -> some View {
            content
                .sheet(item: self.$nav.isRootアListアVesselEdit) { input in
                    VesselEdit(id: input.id, controller: self.controller)
                        .modifier(ListVesselEditReminderEdit())
                        .modifier(ListVesselEditEmoji())
                }
        }
    }
    private struct ListVesselEditReminderEdit: ViewModifier {
        @Nav private var nav
        @EnvironmentObject private var controller: AnyController
        func body(content: Content) -> some View {
            content
                .sheet(item: self.$nav.isRootアListアVesselEditアReminderEdit) { input in
                    ReminderEdit(id: input.reminderID, controller: self.controller)
                }
        }
    }
    private struct ListVesselEditEmoji: ViewModifier {
        @Nav private var nav
        @EnvironmentObject private var controller: AnyController
        func body(content: Content) -> some View {
            content
                .sheet(item: self.$nav.isRootアListアVesselEditアEmoji) { input in
                    VesselEmoji(id: input.vesselID, controller: self.controller)
                }
        }
    }
    private struct ListWatering: ViewModifier {
        @Nav private var nav
        @EnvironmentObject private var controller: AnyController
        func body(content: Content) -> some View {
            content
                .sheet(item: self.$nav.isRootアListアWatering) { input in
                    Watering()
                }
        }
    }
}

