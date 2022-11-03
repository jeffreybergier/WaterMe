//
//  Created by Jeffrey Bergier on 2022/01/24.
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
import Model
import Nav
import Datum
import Umbrella
import Errors
import Localize

struct VesselIconMenu: ViewModifier {

    @Localize.VesselIcon private var text
    @NavVesselEdit private var nav
    @UFErrorQ private var errorQ

    func body(content: Content) -> some View {
        content.modifier(
            JSBConfirmationDialog(item: self.$nav.isIconMenu,
                                  titleKey: self.text(\.titleMenu))
            { input in
                Button(role: nil) { self.nav.isIconEmoji = input }
                           label: { Text(self.text(\.buttonChooseEmoji)) }
                self.camera(input)
                self.library(input)
                // TODO: Figure out how to make this dependent on photo existance
                Button(role: nil) { self.nav.isIconView = input }
                           label: { Text(self.text(\.buttonViewPhoto)) }
                Button(role: .cancel) { }
                               label: { Text(self.text(\.buttonCancel)) }
            }
        )
    }

    private func camera(_ input: VesselInput) -> Button<Text> {
        switch Permission.camera {
        case .allowed:
            return Button(role: nil) { self.nav.isIconCamera = input }
                              label: { Text(self.text(\.buttonChooseCamera)) }
        case .restricted:
            return Button(role: nil) { self.errorQ.append(CameraPermissionError.cameraRestricted) }
                              label: { Text(self.text(\.buttonChooseCameraIssue)) }
        case .denied:
            return Button(role: nil) { self.errorQ.append(CameraPermissionError.cameraDenied) }
                              label: { Text(self.text(\.buttonChooseCameraIssue)) }
        case .incapable:
            return Button(role: nil) { self.errorQ.append(CameraPermissionError.cameraIncapable) }
                              label: { Text(self.text(\.buttonChooseCameraIssue)) }
        }
    }

    private func library(_ input: VesselInput) -> Button<Text> {
        switch Permission.libraryImplicit {
        case true:
            return Button(role: nil) { self.nav.isIconLibrary = input }
                              label: { Text(self.text(\.buttonChoosePhoto)) }
        case false:
            return Button(role: nil) { self.errorQ.append(CameraPermissionError.libraryIncapable) }
                              label: { Text(self.text(\.buttonChoosePhotoIssue)) }
        }
    }
}
