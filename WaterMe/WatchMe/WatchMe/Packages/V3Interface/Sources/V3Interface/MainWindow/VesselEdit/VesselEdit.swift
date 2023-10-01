//
//  Created by Jeffrey Bergier on 2022/11/12.
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

import SwiftUI
import Umbrella
import V3Nav
import V3Model
import V3Datum
import V3Style
import V3Localize

internal struct VesselEdit: View {
    
    @Controller private var controller
    @ErrorStorage private var errors
    
    @V3Style.VesselEdit private var style
    @V3Localize.VesselEdit private var text
    
    @VesselQuery private var vesselQuery
    @ReminderListQuery private var remindersQuery
    
    private let id: Vessel.Identifier
    @Binding private var nav: V3Nav.VesselEdit
    
    internal init(_ id: Vessel.Identifier, nav: Binding<V3Nav.VesselEdit>) {
        _nav = nav
        self.id = id
    }
    
    internal var body: some View {
        self.$vesselQuery.view { vessel in
            Form {
                Section {
                    ZStack {
                        self.style.icon(image: vessel.wrappedValue.icon?.imageValue,
                                        emoji: vessel.wrappedValue.icon?.stringValue)
                        self.style.editPhoto
                                  .action(text: self.text.editPhoto)
                                  .button
                        {
                            self.nav.isPickerMenu = vessel.id
                        }
                    }
                } header: {
                    self.style.sectionHeader
                        .action(text: self.text.photo)
                        .label
                }
                Section {
                    TextField(self.text.name.title, text: vessel.displayName.compactMap())
                } header: {
                    self.style.sectionHeader
                        .action(text: self.text.name)
                        .label
                }
                Section {
                    self.remindersQuery.data.view { reminders in
                        ForEach(reminders) { id in
                            ReminderRow(id) {
                                self.nav.reminderEdit.isPresented = id
                            }
                        }
                    } onEmpty: {
                        self.style.content
                                  .action(text: self.text.notFound)
                                  .label
                                  .preference(key: isFallbackKey.self, value: true)
                    }
                    self.style.button
                        .action(text: self.text.addReminder)
                        .button {
                            self.controller.createReminder(in: vessel.id)
                                .switch(onFailure: self.errors.append)
                            {
                                self.nav.reminderEdit.isPresented = $0
                            }
                        }
                } header: {
                    self.style.sectionHeader
                        .action(text: self.text.reminders)
                        .label
                }
                // TODO: Add Siri Shortcuts Here
                Section {
                    self.style.delete.action(text: self.text.delete).button {
                        let error = DeleteVesselConfirmationError([self.id]) { selection in
                            self.controller.delete(selection)
                                .error
                                .map(self.errors.append(_:))
                        }
                        self.errors.append(error)
                    }
                } header: {
                    self.style.sectionHeader.action(text: self.text.actions).label
                }
            }
        } onNIL: {
            self.style.content
                      .action(text: self.text.notFound)
                      .label
                      .preference(key: isFallbackKey.self, value: true)
        }
        .modifier(IconMenu(isPresented: self.$nav.isPickerMenu, isPicker: self.$nav.isPicker))
        .navigationTitle(self.text.title)
        .onChange(of: self.id, initial: true) { _, newValue in
            self.vesselQuery.identifier = newValue
            self.remindersQuery.filter = .vessel(newValue)
        }
    }
}
