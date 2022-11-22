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
import V3Nav
import V3Model
import V3Datum
import V3Localize

internal struct ErrorPresenter: ViewModifier {
    
    @Nav private var nav
    @Localize private var bundle
    @Controller private var controller
    
    @Environment(\.errorResponder) private var errorResponder
    
    internal init() {}
    
    internal func body(content: Content) -> some View {
        content
            .alert(anyError: self.isError,
                   bundle:   self.bundle,
                   onDismiss: { _ in })
    }
    
    private var isError: Binding<UserFacingError?> {
        Binding {
            guard let error = self.nav.modal.isError else { return nil }
            return self.router(error)
        } set: {
            guard $0 == nil else { return }
            self.nav.modal.isError = nil
        }
    }
    
    private func router(_ input: CodableError) -> any UserFacingError {
        var output: UserFacingError?
        
        switch input.errorDomain {
        case V3Datum.Error.errorDomain:
            output = V3Datum.Error(decode: input)
        case V3Model.DeleteRequestError.errorDomain:
            output = DeleteRequestError(decode: input).map {
                DeleteConfirmationError(request: $0) {
                    $0.vesselID.map { self.controller.delete($0) }?
                         .error.map { self.errorResponder($0) }
                    $0.reminderID.map { self.controller.delete($0) }?
                           .error.map { self.errorResponder($0) }
                }
            }
        default:
            break
        }
        
        return output ?? UnknownError()
    }
}
