//
//  Created by Jeffrey Bergier on 2022/11/27.
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
import V3Settings

extension VesselEdit {
    internal struct IconMenu: ViewModifier {
        
        @Nav private var nav
        @DevicePermissions private var permission
        @V3Style.VesselEdit.IconMenu private var style
        @V3Localize.VesselEdit.IconMenu private var text
        
        @VesselQuery private var query
        
        private var binding: Binding<Vessel.Selection.Element?> {
            self.$nav.modal.isEditPhotoChooser
        }
        
        internal func body(content: Content) -> some View {
            return content
                .onLoadChange(of: self.binding.wrappedValue) {
                    self.query.identifier = $0
                }
                .confirmationDialog(self.text.title,
                                    isPresented: self.binding.mapBool(),
                                    titleVisibility: .automatic,
                                    presenting: self.query.data)
            { vessel in
                self.style.button
                    .action(text: self.text.emoji)
                    .button
                {
                    self.nav.stack.picker(kind: .emoji, for: vessel.id)
                }
                // TODO: In the future, instead of disabling the button
                // change to show error to the user
                self.style.button
                    .action(text: self.text.camera)
                    .button(isEnabled: self.permission.camera.boolValue)
                {
                    self.nav.stack.picker(kind: .camera, for: vessel.id)
                }
                self.style.button
                    .action(text: self.text.library)
                    .button(isEnabled: self.permission.library.boolValue)
                {
                    self.nav.stack.picker(kind: .library, for: vessel.id)
                }
                self.style.button
                    .action(text: self.text.viewCurrent)
                    .button(isEnabled: vessel.icon?.imageValue != nil)
                {
                    self.nav.stack.picker(kind: .viewPhoto, for: vessel.id)
                }
            } message: { _ in
                self.style.message
                    .action(text: self.text.message)
                    .label
            }
        }
    }
}
