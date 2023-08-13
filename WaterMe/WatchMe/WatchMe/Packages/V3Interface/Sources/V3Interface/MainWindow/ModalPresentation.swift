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

internal struct ModalPresentation: ViewModifier {
    
    @Nav private var nav
    
    internal func body(content: Content) -> some View {
        content // Root
            .modifier(ErrorStorage.Presenter(
                isAlreadyPresenting: self.nav.isAlreadyPresenting,
                toPresent: self.$nav.isError,
                router: errorRouter(_:)
            ))
        // MARK: Root:ReminderGrid
        .sheet(item: self.$nav.root.reminderGrid.isPresented) { share in
            ReminderGrid(share, nav: self.$nav.root.reminderGrid)
                .modifier(ErrorStorage.Presenter(
                    isAlreadyPresenting: self.nav.root.reminderGrid.isAlreadyPresenting,
                    toPresent: self.$nav.root.reminderGrid.isError,
                    router: errorRouter(_:)
                ))
            // MARK: Root:ReminderGrid:ReminderSummary
                .sheet(item: self.$nav.root.reminderGrid.reminderSummary.isPresented) {
                    ReminderSummary($0, nav: self.$nav.root.reminderGrid.reminderSummary)
                        .modifier(ErrorStorage.Presenter(
                            isAlreadyPresenting: self.nav.root.reminderGrid.reminderSummary.isAlreadyPresenting,
                            toPresent: self.$nav.root.reminderGrid.reminderSummary.isError,
                            router: errorRouter(_:)
                        ))
                    // MARK: Root:ReminderGrid:ReminderSummary:ReminderEdit
                        .sheet(item: self.$nav.root.reminderGrid.reminderSummary.reminderEdit.isPresented) {
                            ReminderEdit($0, nav: self.$nav.root.reminderGrid.reminderSummary.reminderEdit)
                                .modifier(ErrorStorage.Presenter(
                                    isAlreadyPresenting: self.nav.root.reminderGrid.reminderSummary.reminderEdit.isAlreadyPresenting,
                                    toPresent: self.$nav.root.reminderGrid.reminderSummary.reminderEdit.isError,
                                    router: errorRouter(_:)
                                ))
                        }
                    // MARK: Root:ReminderGrid:ReminderSummary:VesselEdit
                        .sheet(item: self.$nav.root.reminderGrid.reminderSummary.vesselEdit.isPresented) {
                            VesselEdit($0, nav: self.$nav.root.reminderGrid.reminderSummary.vesselEdit)
                                .modifier(ErrorStorage.Presenter(
                                    isAlreadyPresenting: self.nav.root.reminderGrid.reminderSummary.vesselEdit.isAlreadyPresenting,
                                    toPresent: self.$nav.root.reminderGrid.reminderSummary.vesselEdit.isError,
                                    router: errorRouter(_:)
                                ))
                        }

                }
            // MARK: Root:ReminderGrid:VesselEdit
                .sheet(item: self.$nav.root.reminderGrid.vesselEdit.isPresented) {
                    VesselEdit($0, nav: self.$nav.root.reminderGrid.vesselEdit)
                        .modifier(ErrorStorage.Presenter(
                            isAlreadyPresenting: self.nav.root.reminderGrid.vesselEdit.isAlreadyPresenting,
                            toPresent: self.$nav.root.reminderGrid.vesselEdit.isError,
                            router: errorRouter(_:)
                        ))
                }
        }
        // MARK: Root:VesselGrid
        .sheet(item: self.$nav.root.vesselGrid.isPresented) { share in
            VesselGrid(share, nav: self.$nav.root.vesselGrid)
            // MARK: VesselEdit
                .sheet(item: self.$nav.root.vesselGrid.vesselEdit.isPresented) {
                    VesselEdit($0, nav: self.$nav.root.vesselGrid.vesselEdit)
                        .modifier(ErrorStorage.Presenter(
                            isAlreadyPresenting: self.nav.root.vesselGrid.vesselEdit.isAlreadyPresenting,
                            toPresent: self.$nav.root.vesselGrid.vesselEdit.isError,
                            router: errorRouter(_:)
                        ))
                }
        }
        // MARK: Root:VesselEdit
        .sheet(item: self.$nav.root.vesselEdit.isPresented) { vessel in
            VesselEdit(vessel, nav: self.$nav.root.vesselEdit)
        }
    }
}
