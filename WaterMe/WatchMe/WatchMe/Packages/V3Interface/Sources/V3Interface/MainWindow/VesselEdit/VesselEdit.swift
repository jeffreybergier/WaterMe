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
    
    @Nav private var nav
    @Controller private var controller
    @V3Style.VesselEdit private var style
    @V3Localize.VesselEdit private var text
    
    @Environment(\.errorResponder) private var errorResponder
    
    @VesselQuery private var vessel
    @ReminderListQuery private var reminders
    
    private let id: Vessel.Identifier
    
    internal init(_ id: Vessel.Identifier) {
        self.id = id
    }
    
    internal var body: some View {
        self.$vessel.view { vessel in
            Form {
                Section {
                    ZStack {
                        self.style.icon(image: vessel.wrappedValue.icon?.imageValue,
                                        emoji: vessel.wrappedValue.icon?.stringValue)
                        self.style.editPhoto
                                  .action(text: self.text.editPhoto)
                                  .button
                        {
                            self.nav.modal.isEditPhotoChooser = vessel.id
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
                    self.reminders.view { reminders in
                        ForEach(reminders) { id in
                            ReminderRow(id) {
                                self.nav.stack.edit(id)
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
                        .button(action: { self.addReminder(in: vessel.id) })
                } header: {
                    self.style.sectionHeader
                        .action(text: self.text.reminders)
                        .label
                }
                // TODO: Add Siri Shortcuts Here
            }
            .modifier(self.toolbar(vessel.id))
        } onNIL: {
            self.style.content
                      .action(text: self.text.notFound)
                      .label
                      .preference(key: isFallbackKey.self, value: true)
        }
        .onLoadChange(of: self.id) {
            _vessel.setIdentifier($0)
            _reminders.setFilter(.vessel($0))
        }
        .modifier(IconMenu())
    }
    
    private func addReminder(in vesselID: Vessel.Identifier) {
        switch self.controller.createReminder(in: vesselID) {
        case .success(let reminderID):
            self.nav.stack.edit(reminderID)
        case .failure(let error):
            self.errorResponder(error)
        }
    }
    
    private func toolbar(_ id: Vessel.Identifier) -> JSBToolbar {
        return JSBToolbar(
            title: self.text.title,
            delete: self.text.delete,
            deleteAction: {
                self.errorResponder(DeleteRequestError.vessel(id))
            }
        )
    }
}
