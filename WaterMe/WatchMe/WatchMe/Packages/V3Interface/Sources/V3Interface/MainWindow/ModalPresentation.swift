//
//  Created by Jeffrey Bergier on 2023/08/12.
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

internal struct ModalPresentation: ViewModifier {
    
    @Nav private var nav
    
    internal func body(content: Content) -> some View {
        // MARK: /QuickPerform
        content // Root
            .modifier(ErrorStorage.Presenter(
                isAlreadyPresenting: self.nav.isAlreadyPresenting,
                toPresent: self.$nav.isError,
                router: errorRouter(_:)
            ))
        // MARK: /QuickPerform/ReminderGrid
        .sheet(item: self.$nav.root.reminderGrid.isPresented) {
            ReminderGrid.new($0, nav: self.$nav.root.reminderGrid)
        }
        // MARK: /QuickPerform/VesselGrid
        .sheet(item: self.$nav.root.vesselGrid.isPresented) {
            VesselGrid.new($0, nav: self.$nav.root.vesselGrid)
        }
        // MARK: QuickPerform/VesselEdit
        .sheet(item: self.$nav.root.vesselEdit.isPresented) {
            VesselEdit.new($0, nav: self.$nav.root.vesselEdit)
        }
    }
}

extension VesselEdit {
    static func new(_ id: Vessel.Identifier, nav: Binding<V3Nav.VesselEdit>) -> some View {
        // MARK: .../VesselEdit
        VesselEdit(id, nav: nav)
            .modifier(ErrorStorage.Presenter(
                isAlreadyPresenting: nav.wrappedValue.isAlreadyPresenting,
                toPresent: nav.isError,
                router: errorRouter(_:)
            ))
    }
}

extension ReminderEdit {
    static func new(_ id: Reminder.Identifier, nav: Binding<V3Nav.ReminderEdit>) -> some View {
        // MARK: .../ReminderEdit
        ReminderEdit(id, nav: nav)
            .modifier(ErrorStorage.Presenter(
                isAlreadyPresenting: nav.wrappedValue.isAlreadyPresenting,
                toPresent: nav.isError,
                router: errorRouter(_:)
            ))
    }
}

extension ReminderSummary {
    static func new(_ id: Reminder.Identifier, nav: Binding<V3Nav.ReminderSummary>) -> some View {
        // MARK: .../ReminderGrid/ReminderSummary
        ReminderSummary(id, nav: nav)
            .modifier(ErrorStorage.Presenter(
                isAlreadyPresenting: nav.wrappedValue.isAlreadyPresenting,
                toPresent: nav.isError,
                router: errorRouter(_:)
            ))
        // MARK: .../ReminderGrid/ReminderSummary/ReminderEdit
            .sheet(item: nav.reminderEdit.isPresented) {
                ReminderEdit.new($0, nav: nav.reminderEdit)
            }
        // MARK: .../ReminderGrid/ReminderSummary/VesselEdit
            .sheet(item: nav.vesselEdit.isPresented) {
                VesselEdit.new($0, nav: nav.vesselEdit)
            }
    }
}

extension ReminderGrid {
    static func new(_ id: Share.Identifier, nav: Binding<V3Nav.ReminderGrid>) -> some View {
        // MARK: .../ReminderGrid
        ReminderGrid(id, nav: nav)
            .modifier(ErrorStorage.Presenter(
                isAlreadyPresenting: nav.wrappedValue.isAlreadyPresenting,
                toPresent: nav.isError,
                router: errorRouter(_:)
            ))
        // MARK: .../ReminderGrid/ReminderSummary
            .sheet(item: nav.reminderSummary.isPresented) {
                ReminderSummary.new($0, nav: nav.reminderSummary)
            }
        // MARK: .../ReminderGrid/VesselEdit
            .sheet(item: nav.vesselEdit.isPresented) {
                VesselEdit.new($0, nav: nav.vesselEdit)
            }
    }
}

extension VesselGrid {
    static func new(_ id: Share.Identifier, nav: Binding<V3Nav.VesselGrid>) -> some View {
        // MARK: .../VesselGrid
        VesselGrid(id, nav: nav)
            .modifier(ErrorStorage.Presenter(
                isAlreadyPresenting: nav.wrappedValue.isAlreadyPresenting,
                toPresent: nav.isError,
                router: errorRouter(_:)
            ))
        // MARK: .../VesselGrid/VesselEdit
            .sheet(item: nav.vesselEdit.isPresented) {
                VesselEdit.new($0, nav: nav.vesselEdit)
            }
    }
}
