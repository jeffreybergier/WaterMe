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
import Localize

public enum CameraPermissionError: Int, CustomNSError, Codable {

    /// The domain of the error.
    static public var errorDomain: String { "com.saturdayapps.waterme.cameraPermission" }
    /// The error code within the given domain.
    public var errorCode: Int { return self.rawValue }
    /// The user-info dictionary.
    public var errorUserInfo: [String: Any] {
        return [
            NSUnderlyingErrorKey: String(reflecting: self),
        ]
    }

    case cameraDenied
    case cameraRestricted
    case cameraIncapable
    case libraryIncapable
}

extension CameraPermissionError: UserFacingError {

    public var dismissTitle: String { Localize.CameraPermissionError.dismiss }
    public var isCritical: Bool { false }

    public var title: String {
        switch self {
        case .cameraDenied, .cameraRestricted:
            return Localize.CameraPermissionError.titlePermission
        case .cameraIncapable, .libraryIncapable:
            return Localize.CameraPermissionError.titleOther
        }
    }

    public var message: String {
        switch self {
        case .cameraDenied:
            return Localize.CameraPermissionError.messageDenied
        case .cameraRestricted:
            return Localize.CameraPermissionError.messageRestricted
        case .cameraIncapable:
            return Localize.CameraPermissionError.messageIncapableCamera
        case .libraryIncapable:
            return Localize.CameraPermissionError.messageIncapableLibrary
        }
    }
    // TODO: Add settings button to denied error
    public var options: [RecoveryOption] { [] }
}
