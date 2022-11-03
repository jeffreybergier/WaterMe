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
import Errors
import Style
import Localize

internal struct ReminderList: View {

    internal struct Presentation: ViewModifier {

        @NavReminderList private var nav

        internal func body(content: Content) -> some View {
            content
                .modifier(Alert(self.$nav.isError))
                .modifier(OnAppearErrorHandler())
             //  Moved ReminderSummary presentation to ReminderListGrid
             //  Due to the popover needing to be present on the cell
             // .sheet(item: self.$nav.isSummary) { input in
             //     ReminderSummary(rID: input.reminderID,
                .xp_fullScreenCover(item: self.$nav.isWatering) { input in
                    Watering(ids: input.reminderIDs)
                }
                .sheet(item: self.$nav.isReminderEdit) { input in
                    ReminderEdit(id: input.reminderID)
                        .modifier(ReminderEdit.Presentation())
                }
                .sheet(item: self.$nav.isVesselEdit) { input in
                    VesselEdit(id: input.id)
                        .modifier(VesselEdit.Presentation())
                }
                .sheet(isPresented: self.$nav.isSettings) {
                    Settings()
                }
        }
    }

    @UFErrorQ private var errorQ
    @NavReminderList private var nav
    @Localize.ReminderList private var loc
    @ReminderListQuery private var sections
    @ControllerProperty private var controller

    internal var body: some View {
        NavigationView {
            Grid(sections: self.sections) { item in
                self.nav.isSummary = .init(item.id, item.vesselID!)
            }
            .navigationTitle(self.loc(\.title))
            .modifier(ForceNavigationBarTitleDisplayModeInline())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        self.nav.isSettings = true
                    } label: {
                        Text(self.loc(\.buttonSettings))
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        switch self.controller.newVessel() {
                        case .success(let id):
                            self.nav.isVesselEdit = .init(id)
                        case .failure(let error):
                            self.errorQ.append(error)
                        }
                    } label: {
                        Text(self.loc(\.buttonAdd))
                    }
                }
            }
        }
        .modifier(ForceNavigationViewStyleStack())
    }
}
