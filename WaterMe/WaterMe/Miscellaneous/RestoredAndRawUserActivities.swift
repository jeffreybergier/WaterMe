//
//  RawUserActivity.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 10/24/18.
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

import Datum
import CoreSpotlight

public enum RestoredUserActivity {
    case editReminder(Identifier)
    case editReminderVessel(Identifier)
    case viewReminder(Identifier)
    case performReminder(Identifier)
}

public enum RawUserActivity: RawRepresentable {

    case editReminder
    case editReminderVessel
    case viewReminder
    case performReminder
    case indexedItem

    private static let kEditReminder       = "com.saturdayapps.waterme.activity.edit.reminder"
    private static let kEditReminderVessel = "com.saturdayapps.waterme.activity.edit.remindervessel"
    private static let kViewReminder       = "com.saturdayapps.waterme.activity.view.reminder"
    private static let kPerformReminder    = "com.saturdayapps.waterme.activity.perform.reminder"
    private static let kIndexedItem        = CSSearchableItemActionType

    public typealias RawValue = String

    public var rawValue: String {
        switch self {
        case .editReminder:
            return type(of: self).kEditReminder
        case .editReminderVessel:
            return type(of: self).kEditReminderVessel
        case .viewReminder:
            return type(of: self).kViewReminder
        case .performReminder:
            return type(of: self).kPerformReminder
        case .indexedItem:
            return type(of: self).kIndexedItem
        }
    }

    public init?(rawValue: String) {
        switch rawValue {
        case type(of: self).kEditReminder:
            self = .editReminder
        case type(of: self).kEditReminderVessel:
            self = .editReminderVessel
        case type(of: self).kViewReminder:
            self = .viewReminder
        case type(of: self).kPerformReminder:
            self = .performReminder
        case type(of: self).kIndexedItem:
            self = .indexedItem
        default:
            return nil
        }
    }
}
