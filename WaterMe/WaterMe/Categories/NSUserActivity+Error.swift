//
//  NSUserActivity+Error.swift
//  WaterMeData
//
//  Created by Jeffrey Bergier on 10/7/18.
//  Copyright © 2018 Saturday Apps.
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
import DatumL
import Foundation

public enum UserActivityError: Error {
    case perform, reminderNotFound, reminderVesselNotFound, siriShortcutCreate
}

extension UserActivityError: UserFacingError {

    public var isCritical: Bool {
        switch self {
        case .perform, .siriShortcutCreate:
            return true
        case .reminderNotFound, .reminderVesselNotFound:
            return false
        }
    }

    public var title: String? {
        switch self {
        case .perform, .siriShortcutCreate:
            return LocalizedString.siriShortcutGenericErrorAlertTitle
        case .reminderNotFound:
            return LocalizedString.siriShortcutReminderNotFoundErrorAlertTitle
        case .reminderVesselNotFound:
            return LocalizedString.siriShortcutReminderVesselNotFoundErrorAlertTitle
        }
    }

    public var message: String? {
        switch self {
        case .siriShortcutCreate:
            return LocalizedString.siriShortcutCreateErrorAlertMessage
        case .perform:
            return LocalizedString.siriShortcutContinuationErrorAlertMessage
        case .reminderNotFound:
            return LocalizedString.siriShortcutReminderNotFoundErrorAlertMessage
        case .reminderVesselNotFound:
            return LocalizedString.siriShortcutReminderVesselNotFoundErrorAlertMessage
        }
    }

    public var recoveryActions: [RecoveryAction] {
        switch self {
        case .siriShortcutCreate:
            return [.dismiss]
        case .reminderNotFound, .reminderVesselNotFound, .perform:
            return [.dismiss, .openWaterMeSettings]
        }
    }
}
