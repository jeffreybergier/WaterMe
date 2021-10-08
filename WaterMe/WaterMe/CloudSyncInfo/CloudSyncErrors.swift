//
//  CloudSyncErrors.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 2021/05/05.
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

import Calculate

extension CloudKitSyncError: UserFacingError {
    public var isCritical: Bool { false }
    public var title: String? { CloudSyncProgressView.LocalizedString.errorAlertTitle }
    public var message: String? {
        let localizedMessage: String
        switch self.typed {
        case .storageLimit:
            localizedMessage = CloudSyncProgressView.LocalizedString.errorStorageLimitAlertMessage
        case .rateLimit:
            localizedMessage = CloudSyncProgressView.LocalizedString.errorRateLimitAlertMessage
        case .password:
            localizedMessage = CloudSyncProgressView.LocalizedString.errorPasswordAlertMessage
        case .network:
            localizedMessage = CloudSyncProgressView.LocalizedString.errorNetworkAlertMessage
        case .partialSync:
            localizedMessage = CloudSyncProgressView.LocalizedString.errorPartialSyncAlertMessage
        case .unknownUnknown, .knownUnknown:
            localizedMessage = CloudSyncProgressView.LocalizedString.errorUnknownAlertMessage
        }
        return localizedMessage + "(\(self.untyped.domain): \(self.untyped.code))"
    }
    public var recoveryActions: [RecoveryAction] {
        switch self.typed {
        case .password, .storageLimit:
            return [.openWaterMeSettings]
        case .unknownUnknown, .knownUnknown, .network, .rateLimit, .partialSync:
            return []
        }
    }
}

extension GenericInitializationError: UserFacingError {
    public var title: String? { CloudSyncProgressView.LocalizedString.errorAlertTitle }
    public var message: String? {
        switch self {
        case .couldNotDetermine:
            return CloudSyncProgressView.LocalizedString.notDeterminedErrorAlertMessage
        case .restricted:
            return CloudSyncProgressView.LocalizedString.restrictedErrorAlertMessage
        case .noAccount:
            return CloudSyncProgressView.LocalizedString.iCloudLoggedOutErrorAlertMessage
        case .noPassword:
            return CloudSyncProgressView.LocalizedString.iCloudNoPasswordErrorAlertMessage
        }
    }
    public var recoveryActions: [RecoveryAction] { [.openWaterMeSettings] }
    public var isCritical: Bool { false }
    public static var errorDomain: String { "com.saturdayapps.waterme.GenericInitializationError" }
    public var errorCode: Int {
        switch self {
        case .couldNotDetermine:
            return 1001
        case .restricted:
            return 1002
        case .noAccount:
            return 1003
        case .noPassword:
            return 1004
        }
    }
}

extension CloudSyncProgressView {
    enum Error: UserFacingError {
        static var errorDomain: String { "com.saturdayapps.waterme.CloudSyncProgressView" }
        case notAvailable
        var errorCode: Int {
            switch self {
            case .notAvailable:
                return 1001
            }
        }
        var title: String? { LocalizedString.errorAlertTitle }
        var message: String? {
            switch self {
            case .notAvailable:
                return CloudSyncProgressView.LocalizedString.unsupportedDeviceErrorAlertMessage
            }
        }
        var recoveryActions: [RecoveryAction] { [.openWaterMeSettings] }
        var isCritical: Bool { false }
    }
}
