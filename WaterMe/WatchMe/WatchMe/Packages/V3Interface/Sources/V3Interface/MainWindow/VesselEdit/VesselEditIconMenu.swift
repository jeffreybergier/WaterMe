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
        
        @DevicePermissions private var permission
        @V3Style.VesselEdit.IconMenu private var style
        @V3Localize.VesselEdit.IconMenu private var text
        
        @VesselQuery private var query
        @Binding internal var isPresented: Vessel.Identifier?
        @Binding internal var isPicker: PickerKind?
        
        /// Combines the `isPresented` binding with the `VesselQuery` so they are never out of sync
        private var isPresentedBinding: Binding<Vessel?> {
            guard self.isPresented != nil else { return .constant(nil) }
            return .init {
                self.query.data
            } set: {
                guard $0 == nil else { return }
                self.isPresented = nil
            }
        }
        
        internal func body(content: Content) -> some View {
            return content
                .onChange(of: self.isPresented, initial: true) { _, newValue in
                    self.query.identifier = newValue
                }
                .confirmationDialog(item: self.isPresentedBinding,
                                    title: self.text.title)
            { vessel in
                self.style.button
                    .action(text: self.text.emoji)
                    .button
                {
                    self.isPicker = .emoji
                }
                // TODO: In the future, instead of disabling the button
                // change to show error to the user
                self.style.button
                    .action(text: self.text.camera)
                    .button(isEnabled: self.permission.camera.boolValue)
                {
                    self.isPicker = .camera
                }
                self.style.button
                    .action(text: self.text.library)
                    .button(isEnabled: self.permission.library.boolValue)
                {
                    self.isPicker = .library
                }
                self.style.button
                    .action(text: self.text.viewCurrent)
                    .button(isEnabled: vessel.icon?.imageValue != nil)
                {
                    self.isPicker = .viewPhoto
                }
            } message: { _ in
                self.style.message
                    .action(text: self.text.message)
                    .label
            }
        }
    }
}
