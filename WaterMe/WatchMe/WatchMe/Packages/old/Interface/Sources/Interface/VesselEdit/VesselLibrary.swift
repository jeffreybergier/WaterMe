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
import Nav
import Model
import Errors

internal struct VesselLibrary: View {

    internal struct Presentation: ViewModifier {
        @NavGeneric private var nav
        func body(content: Content) -> some View {
            content
                .modifier(Alert(self.$nav.isError))
                .modifier(OnAppearErrorHandler())
        }
    }

    @State private var uncleanResult: CameraResult?
    @VesselEditQuery private var vessel: Vessel
    @UFErrorQ private var errorQ
    @Environment(\.dismiss) private var dismiss

    internal init(id: Vessel.アイディ) {
        _vessel = VesselEditQuery(id: id)
    }

    internal var body: some View {
        LibraryPicker() { result in
            self.uncleanResult = result
            self.dismiss()
        }
        .onDisappear {
            switch self.uncleanResult {
            case .success(let uncleanData):
                self.vessel.icon = .init(uncleanData: uncleanData)
            case .failure(let error):
                self.errorQ.append(error)
            case .none:
                break
            }
        }
    }
}
