//
//  UserFacingError.swift
//  WaterMeData
//
//  Created by Jeffrey Bergier on 10/10/18.
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

import Foundation

public enum RecoveryAction {
    case openWaterMeSettings
    case reminderMissingMoveLocation
    case reminderMissingOtherDescription
    case reminderMissingEnabled
    case reminderVesselMissingIcon
    case reminderVesselMissingName
    case reminderVesselMissingReminder
    case cancel
    case dismiss
    case saveAnyway
}

public protocol UserFacingError: CustomNSError {
    var isCritical: Bool { get }
    var title: String? { get }
    var message: String? { get }
    var recoveryActions: [RecoveryAction] { get }
}

public protocol RecoveryActionSelectable: Swift.Error {
    var title: String { get }
    var automaticExecution: (() -> Void)? { get }
}
