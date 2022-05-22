//
//  Created by Jeffrey Bergier on 2022/02/04.
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
import Umbrella
import Datum
import Errors
import Model
import Nav
import Style
import Localize

internal struct VesselEdit: View {
    
    internal struct Presentation: ViewModifier {
        
        @NavVesselEdit private var nav
        
        internal func body(content: Content) -> some View {
            content
                .modifier(Alert(self.$nav.isError))
                .modifier(OnAppearErrorHandler())
                .modifier(VesselIconMenu())
                .sheet(item: self.$nav.isReminderEdit) { input in
                    ReminderEdit(id: input.reminderID)
                        .modifier(ReminderEdit.Presentation())
                }
                .sheet(item: self.$nav.isIconEmoji) { input in
                    VesselEmoji(id: input.vesselID)
                        .modifier(VesselEmoji.Presentation())
                }
                .xp_fullScreenCover(item: self.$nav.isIconCamera) { input in
                    VesselCamera(id: input.vesselID)
                        .modifier(VesselCamera.Presentation())
                }
                .xp_fullScreenCover(item: self.$nav.isIconLibrary) { input in
                    VesselLibrary(id: input.vesselID)
                        .modifier(VesselLibrary.Presentation())
                }
        }
    }
    
    @VesselEditQuery private var vessel: Vessel
    @VesselEditReminderQuery private var reminders: AnyRandomAccessCollection<Reminder>
    @ControllerProperty private var controller
    
    @UFErrorQ private var errorQ
    @Style.Form private var style
    @NavVesselEdit private var nav
    @Localize.VesselEdit private var text
    @Environment(\.dismiss) private var dismiss
    @EnvironmentBundle<ImageBundle> private var image
    
    internal init(id: Vessel.アイディ) {
        _vessel = VesselEditQuery(id: id)
        _reminders = VesselEditReminderQuery(id: id)
    }
    
    internal var body: some View {
        NavigationView {
            Form {
                Section {
                    ZStack {
                        VesselIcon(icon: self.vessel.icon)
                        Button {
                            self.nav.isIconMenu = .init(self.vessel.id)
                        } label: {
                            self.image.camera
                                .modifier(ButtonModifier(role: .normal))
                        }
                    }
                    .modifier(CenterModifier())
                    .modifier(self.style.sectionPaddingTop)
                    .modifier(self.style.sectionPaddingBottom)
                } header: {
                    Text(self.text(\.sectionPhoto))
                        .modifier(self.style.sectionTitle)
                }
                Section {
                    JSBTextField(self.text(\.placeholderPlantName), text: self.$vessel.displayName)
                        .modifier(self.style.subsectionData)
                        .modifier(self.style.sectionPaddingTop)
                        .modifier(self.style.sectionPaddingBottom)
                } header: {
                    Text(self.text(\.sectionName))
                        .modifier(self.style.sectionTitle)
                }
                Section {
                    List(self.reminders) { item in
                        Button {
                            self.nav.isReminderEdit = .init(item.id)
                        } label: {
                            ReminderCell(id: item.id)
                        }
                    }
                    .modifier(self.style.sectionPaddingTop)
                    Button {
                        switch self.controller.newReminder(for: self.vessel.id) {
                        case .success(let reminder):
                            self.nav.isReminderEdit = .init(reminder)
                        case .failure(let error):
                            self.errorQ.append(error)
                        }
                    } label: {
                        Text(self.text(\.buttonAddReminder))
                    }
                    .modifier(ButtonModifier(role: .normal))
                    .modifier(self.style.sectionPaddingBottom)
                } header: {
                    Text(self.text(\.sectionReminders))
                        .modifier(self.style.sectionTitle)
                }
                XPSiriShortcuts()
            }
            .navigationTitle(self.text(\.title))
            .modifier(ForceNavigationBarTitleDisplayModeInline())
            .modifier(
                XPDoneDeleteToolbar(
                    onDone: { self.dismiss() },
                    onDelete: .generic {
                        self.controller.delete(self.vessel.id).error
                            .map { self.errorQ.append($0) }
                    }
                )
            )
            .onChange(of: self.vessel.isDeleted) { isDeleted in
                guard isDeleted else { return }
                self.dismiss()
            }
        }
    }
}
