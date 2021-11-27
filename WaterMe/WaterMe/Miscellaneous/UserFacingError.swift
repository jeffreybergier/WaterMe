//
//  UserFacingErrors.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 16/1/18.
//  Copyright © 2017 Saturday Apps.
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
import Datum

extension DatumError: UserFacingError {

    public var isCritical: Bool {
        switch self {
        case .load, .write, .read, .objectMissing, .cannotCompressImageEnough, .maintenance:
            return true
        case .cannotDeleteLastReminder, .reminderIsEnabledFlagUnavailable:
            return false
        }
    }

    public var title: String? {
        switch self {
        case .cannotDeleteLastReminder:
            return LocalizedString.deleteTitle
        case .load:
            return LocalizedString.loadTitle
        case .cannotCompressImageEnough:
            return LocalizedString.saveImageTitle
        default:
            return LocalizedString.saveTitle
        }
    }

    public var message: String? {
        switch self {
        case .cannotCompressImageEnough:
            return LocalizedString.saveImageMessage
        case .objectMissing:
            return LocalizedString.objectDeletedMessage
        case .load, .read:
            return LocalizedString.loadMessage
        case .write:
            return LocalizedString.saveMessage
        case .cannotDeleteLastReminder:
            return LocalizedString.deleteMessage
        case .reminderIsEnabledFlagUnavailable:
            return LocalizedString.realmIsEnabledFalseUnsupportedMessage
        case .maintenance:
            return LocalizedString.maintenanceMessage
        }
    }

    public var recoveryActions: [RecoveryAction] {
        switch self {
        case .objectMissing,
             .cannotDeleteLastReminder,
             .cannotCompressImageEnough,
             .reminderIsEnabledFlagUnavailable,
             .maintenance:
            return [.dismiss]
        case .load, .read, .write:
            return [.dismiss, .openWaterMeSettings]
        }
    }
}

extension RecoveryAction: RecoveryActionSelectable {

    public var title: String {
        switch self {
        case .cancel:
            return UIAlertController.LocalizedString.buttonTitleCancel
        case .dismiss:
            return UIAlertController.LocalizedString.buttonTitleDismiss
        case .saveAnyway:
            return UIAlertController.LocalizedString.buttonTitleSaveAnyway
        case .openWaterMeSettings:
            return SettingsMainViewController.LocalizedString.cellTitleOpenSettings
        case .reminderMissingMoveLocation:
            return LocalizedString.missingLocation
        case .reminderMissingOtherDescription:
            return LocalizedString.missingDescription
        case .reminderMissingEnabled:
            return LocalizedString.missingEnabled
        case .reminderVesselMissingIcon:
            return LocalizedString.missingPhoto
        case .reminderVesselMissingName:
            return LocalizedString.missingName
        case .reminderVesselMissingReminder:
            return LocalizedString.missingReminders
        }
    }

    public var automaticExecution: (() -> Void)? {
        switch self {
        case .openWaterMeSettings:
            return { UIApplication.shared.openAppSettings(completion: nil) }
        default:
            return nil
        }
    }

    internal var actionStyle: UIAlertAction.Style {
        switch self {
        case .cancel, .dismiss:
            return .cancel
        case .saveAnyway:
            return .destructive
        default:
            return .default
        }
    }
}

extension ModelCompleteError: UserFacingError {

    public var isCritical: Bool {
        return false
    }

    public var title: String? {
        return UIAlertController.LocalizedString.titleUnsolvedIssues
    }

    public var message: String? {
        return nil
    }

    public var recoveryActions: [RecoveryAction] {
        return self._actions
    }
}
