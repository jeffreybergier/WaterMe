//
//  Created by Jeffrey Bergier on 2022/11/12.
//
//  Copyright © 2022 Saturday Apps.
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
import V3Model
import V3Nav
import V3Localize

internal struct NavigationRouter: ViewModifier {
    
    @Nav private var nav
    @ErrorStorage private var store
    
    internal init() {}
    
    internal func body(content: Content) -> some View {
        // TODO: Make it so Views never touch Nav directly...
        // or rather they only says "Do List of this", "Edit this", "pop to this", etc
        NavigationStack(path: self.$nav.stack.path) {
            content
                .navigationDestination(for: Nav.Special<Share.Identifier>.self) {
                    ReminderGrid($0.id)
                }
                .navigationDestination(for: Nav.List<Share.Identifier>.self) {
                    VesselGrid($0.id)
                }
                .navigationDestination(for: Nav.View<Reminder.Identifier>.self) {
                    ReminderSummary($0.id)
                }
                .navigationDestination(for: Nav.Edit<Vessel.Identifier>.self) {
                    VesselEdit($0.id)
                }
                .navigationDestination(for: Nav.Edit<Reminder.Identifier>.self) {
                    ReminderEdit($0.id)
                }
                .navigationDestination(for: Nav.Picker<Vessel.Identifier>.self) {
                    switch $0.kind {
                    case .emoji: VesselEdit.EmojiPicker(id: $0.id)
                    case .camera: fatalError()
                    case .library: VesselEdit.LibraryPicker(id: $0.id)
                    case .viewPhoto: fatalError()
                    }
                }
        }
        .modifier(
            ErrorStorage.Presenter(
                isAlreadyPresenting: self.nav.modal.isAlreadyPresenting,
                toPresent: self.$nav.modal.isError,
                router: errorRouter(_:)
            )
        )
    }
}
