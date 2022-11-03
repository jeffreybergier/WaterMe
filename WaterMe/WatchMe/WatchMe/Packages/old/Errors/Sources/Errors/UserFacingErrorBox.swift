//
//  Created by Jeffrey Bergier on 2022/02/05.
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

import Foundation
import Umbrella
import Datum

internal struct UserFacingErrorBox: Codable {

    internal var error: UserFacingError?

    internal init(_ error: UserFacingError?) {
        self.error = error
    }

    private enum CodingKeys: String, CodingKey {
         case datum, camera, cameraPermission
    }

    internal func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self.error {
        case let error as Datum.Error:
            try c.encode(error, forKey: .datum)
        case let error as CameraError:
            try c.encode(error, forKey: .camera)
        case let error as CameraPermissionError:
            try c.encode(error, forKey: .cameraPermission)
        default:
            assertionFailure("Hit unknown error type")
            break
        }
    }

    internal init(from decoder: Decoder) throws {
        let d = try decoder.container(keyedBy: CodingKeys.self)
        if let error = try? d.decode(Datum.Error.self, forKey: .datum) {
            self.error = error
        } else if let error = try? d.decode(CameraError.self, forKey: .camera) {
            self.error = error
        } else if let error = try? d.decode(CameraPermissionError.self, forKey: .cameraPermission) {
            self.error = error
        } else {
            assertionFailure("Hit unknown error type")
            self.error = nil
        }
    }
}
