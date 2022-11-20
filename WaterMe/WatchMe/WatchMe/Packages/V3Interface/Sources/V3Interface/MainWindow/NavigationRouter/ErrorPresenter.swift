//
//  Created by Jeffrey Bergier on 2022/11/20.
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
import V3Localize
import V3Nav

internal struct ErrorPresenter: ViewModifier {
    
    @Nav private var nav
    @Localize private var bundle
    
    internal init() {}
    
    internal func body(content: Content) -> some View {
        content
            .alert(anyError: self.isError,
                   bundle:   self.bundle,
                   onDismiss: { _ in })
    }
    
    // TODO: Consider making typed properties for the UserFacingErrors
    private var isError: Binding<UserFacingError?> {
        Binding {
            self.nav.modal.isError?.userFacingError
        } set: {
            guard $0 == nil else { return }
            self.nav.modal.isError = nil
        }
    }
}
