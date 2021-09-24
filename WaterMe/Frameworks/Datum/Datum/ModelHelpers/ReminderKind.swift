//
//  ReminderKind.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/05/21.
//  Copyright © 2020 Saturday Apps.
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

public enum ReminderVesselKind: String {
    case plant
}

public enum ReminderKind: Hashable {
    case water, fertilize, trim, mist, move(location: String?), other(description: String?)
    public static let count = 6
}

extension ReminderKind {

    internal static let kCaseWaterValue = "kReminderKindCaseWaterValue"
    fileprivate static let kCaseTrimValue = "kReminderKindCaseTrimValue"
    fileprivate static let kCaseMistValue = "kReminderKindCaseMistValue"
    fileprivate static let kCaseFertilizeValue = "kReminderKindCaseFertilizeValue"
    fileprivate static let kCaseMoveValue = "kReminderKindCaseMoveValue"
    fileprivate static let kCaseOtherValue = "kReminderKindCaseOtherValue"

    internal typealias RawValue = (primary: String, secondary: String?)

    internal var rawValue: RawValue {
        let me = type(of: self)
        switch self {
        case .water:
            return (me.kCaseWaterValue, nil)
        case .fertilize:
            return (me.kCaseFertilizeValue, nil)
        case .trim:
            return (me.kCaseTrimValue, nil)
        case .mist:
            return (me.kCaseMistValue, nil)
        case .move(let location):
            return (me.kCaseMoveValue, location)
        case .other(let description):
            return (me.kCaseOtherValue, description)
        }
    }

    init(rawValue: RawValue) {
        switch rawValue.primary {
        case type(of: self).kCaseWaterValue:
            self = .water
        case type(of: self).kCaseFertilizeValue:
            self = .fertilize
        case type(of: self).kCaseTrimValue:
            self = .trim
        case type(of: self).kCaseMistValue:
            self = .mist
        case type(of: self).kCaseMoveValue:
            let description = rawValue.secondary
            self = .move(location: description)
        case type(of: self).kCaseOtherValue:
            let description = rawValue.secondary
            self = .other(description: description)
        default:
            fatalError("Reminder.Kind: Invalid Case String Key")
        }
    }
}
