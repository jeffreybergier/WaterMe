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

import Umbrella
import V3Localize

// TODO: Fix error router
internal func errorRouter(_ input: Swift.Error) -> any UserFacingError {
    return UnknownError()
    /*
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
    */
}
