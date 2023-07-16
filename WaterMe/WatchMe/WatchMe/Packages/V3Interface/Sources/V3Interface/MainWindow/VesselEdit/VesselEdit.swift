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
                            // TODO: Nav
                            // self.nav.modal.isEditPhotoChooser = vessel.id
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
                                // TODO: Nav
                                // self.nav.stack.edit(id)
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
            .modifier(self.toolbar)
        } onNIL: {
            self.style.content
                      .action(text: self.text.notFound)
                      .label
                      .preference(key: isFallbackKey.self, value: true)
        }
        .onLoadChange(of: self.id) {
            self.vesselQuery.identifier = $0
            self.remindersQuery.filter = .vessel($0)
        }
        .modifier(IconMenu(nav: self.$nav.reminderEdit))
    }
    
    private func addReminder(in vesselID: Vessel.Identifier) {
        switch self.controller.createReminder(in: vesselID) {
        case .success(let reminderID):
            // TODO: Nav
            // self.nav.stack.edit(reminderID)
            break
        case .failure(let error):
            self.errors.append(error)
        }
    }
    
    private var toolbar: some ViewModifier {
        return JSBToolbar(
            title:  self.text.title,
            done:   self.text.done,
            delete: self.text.delete,
            doneAction: { /* // TODO: Nav */ },
            deleteAction: {
                let error = DeleteVesselConfirmationError([self.id]) { selection in
                    self.controller.delete(selection)
                        .error
                        .map(self.errors.append(_:))
                }
                self.errors.append(error)
            }
        )
    }
}


// Debugging this stupid toolbar problem
public struct JSBToolbar_iOS_Temp: ViewModifier {

    private var title:  LocalizedString
    private var done:   ActionLocalization?
    private var cancel: ActionLocalization?
    private var delete: ActionLocalization?
    
    public var actionDone:   (() -> Void)?
    public var actionCancel: (() -> Void)?
    public var actionDelete: (() -> Void)?

    public init(title:  LocalizedString,
                done:   ActionLocalization? = nil,
                cancel: ActionLocalization? = nil,
                delete: ActionLocalization? = nil,
                doneAction:   (() -> Void)? = nil,
                cancelAction: (() -> Void)? = nil,
                deleteAction: (() -> Void)? = nil)
    {
        self.title = title
        self.done = done
        self.cancel = cancel
        self.delete = delete
        self.actionDone = doneAction
        self.actionCancel = cancelAction
        self.actionDelete = deleteAction
    }
    
    public func body(content: Content) -> some View {
        content
            .navigationTitle(self.title)
            .navigationBarTitleDisplayModeInline
            .if(value: self.done) { view, done in
                view.toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        JSBToolbarButtonStyleDone
                            .action(text: done)
                            .button(item: self.actionDone, action: { $0() })
                    }
                }
            }
            .if(value: self.cancel) { view, cancel in
                view.toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        JSBToolbarButtonStyleCancel
                            .action(text: cancel)
                            .button(item: self.actionCancel, action: { $0() })
                    }
                }
            }
            .if(value: self.delete) { view, delete in
                view.toolbar {
                    // TODO: This should be `.destructiveAction` but the toolbar
                    // places this on the right side of the title with the ConfirmationAction.
                    // Configuring as `.cancellationAction` to place button on Left
                    ToolbarItem(placement: .cancellationAction) {
                        JSBToolbarButtonStyleDelete
                            .action(text: delete)
                            .button(item: self.actionDelete, action: { $0() })
                    }
                }
            }
    }
}
