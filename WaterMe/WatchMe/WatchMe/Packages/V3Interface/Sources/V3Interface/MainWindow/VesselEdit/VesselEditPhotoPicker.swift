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

extension VesselEdit {
    internal struct EditPhotoPicker: ViewModifier {
        
        @Nav private var nav
        @V3Style.VesselEdit.EditPhotoPicker private var style
        @V3Localize.VesselEdit.EditPhotoPicker private var text
        
        @VesselQuery private var vessel
        
        private var binding: Binding<Vessel.Selection.Element?> {
            self.$nav.modal.isEditPhotoChooser
        }
        
        internal func body(content: Content) -> some View {
            return content
                .onLoadChange(of: self.binding.wrappedValue) {
                    _vessel.setIdentifier($0)
                }
                .confirmationDialog(self.text.title,
                                    isPresented: self.binding.isPresented(),
                                    titleVisibility: .automatic,
                                    presenting: self.vessel)
            { vessel in
                self.style.button
                    .action(text: self.text.emoji)
                    .button
                {
                    self.nav.stack.picker(kind: .emoji, for: vessel.id)
                }
                self.style.button
                    .action(text: self.text.camera)
                    .button
                {
                    self.nav.stack.picker(kind: .camera, for: vessel.id)
                }
                self.style.button
                    .action(text: self.text.library)
                    .button
                {
                    self.nav.stack.picker(kind: .emoji, for: vessel.id)
                }
                if vessel.icon?.imageValue != nil {
                    self.style.button
                        .action(text: self.text.viewCurrent)
                        .button
                    {
                        self.nav.stack.picker(kind: .viewPhoto, for: vessel.id)
                    }
                }
            } message: { _ in
                self.style.message
                    .action(text: self.text.message)
                    .label
            }
        }
    }
}
