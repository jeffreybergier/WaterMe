//
//  Created by Jeffrey Bergier on 2023/05/27.
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

#if os(watchOS)

import SwiftUI
import Umbrella
import V3Model
import V3Datum
import V3Nav
import V3Localize
import V3Style
import V3Settings

internal struct QuickPerform: View {
    
    @Controller private var controller
    @ErrorStorage private var errors
    
    @V3Style.QuickPerform private var style
    @V3Localize.QuickPerform private var text
    @V3Settings.FeatureFlags private var features
    
    @ReminderListQuery(.lateAndToday) private var query
    
    private let id: Share.Identifier
    @Binding private var nav: V3Nav.QuickPerform
    
    internal init(_ id: Share.Identifier, nav: Binding<V3Nav.QuickPerform>) {
        self.id = id
        _nav = nav
    }
    
    internal var body: some View {
        TabView {
            self.query.data.view { data in
                Tab(data: data, section: self.query.section) {
                    self.presentHamburgerMenu()
                }
            } onEmpty: {
                Button {
                    self.presentHamburgerMenu()
                } label: {
                    self.style.icon(image: self.text.feelGoodImage,
                                    subtitle: self.text.feelGoodMessage)
                }
                .buttonStyle(.plain)
            }
        }
        .tabViewStyle(.verticalPage)
        .navigationTitle(self.text.title)
        .onChange(of: self.id, initial: true) { _, newValue in
            self.query.filter = .share(newValue)
        }
        .confirmationDialog(self.text.menuTitle(self.nav.hamburgerMenu.selection.count),
                            isPresented: self.$nav.hamburgerMenu.isPresented,
                            presenting: self.nav.hamburgerMenu.selection)
        { reminders in
            self.style.button
                .action(text: self.text.menuButtonMarkAsDone)
                .button(isEnabled: reminders.isEmpty == false && self.features.contains(.performReminder))
            {
                self.controller
                    .appendNewPerformToReminders(with: reminders)
                    .switch(onFailure: self.errors.append)
                {
                    self.presentWateringAnimation(reminders)
                }
            }
            self.style.button
                .action(text: self.text.addPlant)
                .button(isEnabled: self.features.contains(.addVessel))
            {
                self.controller.createVessel().switch(onFailure: self.errors.append) {
                    self.presentVesselEdit($0)
                }
            }
            self.style.button.action(text: self.text.menuButtonViewAll).button {
                self.presentReminderGrid()
            }
        } message: { _ in EmptyView() }
    }
    
    private func presentHamburgerMenu() {
        // TODO: Hack to make sure that the reminder grid can be presented reliably
        self.nav.reminderGrid.isPresented = nil
        // end TODO:
        self.nav.hamburgerMenu.isPresented = true
        self.nav.hamburgerMenu.selection = Set(self.query.data)
    }
    
    private func presentReminderGrid() {
        self.nav.reminderGrid.isPresented = self.id
    }
    
    private func presentVesselEdit(_ vessel: Vessel.Identifier) {
        self.nav.vesselEdit.isPresented = vessel
    }
    
    private func presentWateringAnimation(_ reminders: Reminder.Selection) {
        self.nav.isWatering = reminders
    }
}

#endif
