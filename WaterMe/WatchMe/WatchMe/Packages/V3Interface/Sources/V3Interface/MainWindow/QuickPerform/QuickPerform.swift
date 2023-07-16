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

internal struct QuickPerform: View {
    
    @V3Style.QuickPerform private var style
    @V3Localize.QuickPerform private var text
    
    private let id: Share.Identifier
    @Binding private var nav: V3Nav.QuickPerform
    
    internal init(_ id: Share.Identifier, nav: Binding<V3Nav.QuickPerform>) {
        _nav = nav
        self.id = id
    }
    
    internal var body: some View {
        TabView {
            QuickPerformTab(self.id, section: .late)
            QuickPerformTab(self.id, section: .today)
            QuickPerformTab(self.id, section: .tomorrow)
        }
        .tabViewStyle(.verticalPage)
        .navigationTitle(self.text.title)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()
                self.style.buttonToolbar.action(text: self.text.hamburger).button {
                    self.nav.isHamburgerMenu = true
                }
            }
        }
        .modifier(QuickPerformModalPresentation(self.id, nav: self.$nav))

    }
}

// MARK: Modal Presentation

internal struct QuickPerformModalPresentation: ViewModifier {
    
    @Controller private var controller
    @ErrorStorage private var errors
    
    @V3Style.QuickPerform private var style
    @V3Localize.QuickPerform private var text
    
    private let id: Share.Identifier
    @Binding private var nav: V3Nav.QuickPerform
    
    internal init(_ id: Share.Identifier, nav: Binding<V3Nav.QuickPerform>) {
        _nav = nav
        self.id = id
    }
    
    internal func body(content: Content) -> some View {
        content
        // Hamburger Menu
            .confirmationDialog("", isPresented: self.$nav.isHamburgerMenu) {
                self.style.button.action(text: self.text.addPlant).button {
                    let result = self.controller.createVessel()
                    switch result {
                    case .success(let id):
                        self.nav.vesselEdit.isPresented = id
                    case .failure(let error):
                        self.errors.append(error)
                    }
                }
                Button("View All Reminders") {
                    self.nav.reminderGrid.isPresented = self.id
                }
            }
        // Reminder Grid
            .sheet(item: self.$nav.reminderGrid.isPresented) { share in
                ReminderGrid(share, nav: self.$nav.reminderGrid)
            }
        // Vessel Edit
            .sheet(item: self.$nav.vesselEdit.isPresented) { vessel in
                VesselEdit(vessel, nav: self.$nav.vesselEdit)
            }
    }
}

#endif
