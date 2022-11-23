//
//  Created by Jeffrey Bergier on 2022/11/13.
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

import Umbrella

/*
 
 extension ReminderHours {
     internal var localized: LocalizationKey {
         switch self {
         case .hour4:
             return Label.time4
         case .hour5:
             return Label.time5
         case .hour6:
             return Label.time6
         case .hour7:
             return Label.time7
         case .hour8:
             return Label.time8
         case .hour9:
             return Label.time9
         case .hour10:
             return Label.time10
         case .hour11:
             return Label.time11
         case .hour12:
             return Label.time12
         case .hour13:
             return Label.time13
         case .hour14:
             return Label.time14
         case .hour15:
             return Label.time15
         case .hour16:
             return Label.time16
         case .hour17:
             return Label.time17
         case .hour18:
             return Label.time18
         case .hour19:
             return Label.time19
         case .hour20:
             return Label.time20
         case .hour21:
             return Label.time21
         case .hour22:
             return Label.time22
         case .hour23:
             return Label.time23
         }
     }
 }
 
extension ReminderDays {
    internal var localized: LocalizationKey {
        switch self {
        case .days7:
            return Label.days7
        case .days8:
            return Label.days8
        case .days9:
            return Label.days9
        case .days10:
            return Label.days10
        case .days11:
            return Label.days11
        case .days12:
            return Label.days12
        case .days13:
            return Label.days13
        case .days14:
            return Label.days14
        case .days15:
            return Label.days15
        case .days16:
            return Label.days16
        case .days17:
            return Label.days17
        case .days18:
            return Label.days18
        case .days19:
            return Label.days19
        case .days20:
            return Label.days20
        case .days21:
            return Label.days21
        }
    }
}
*/

/*
extension DarkMode {
    internal var localized: LocalizationKey {
        switch self {
        case .system:
            return Label.changeWithSystem
        case .forceLight:
            return Label.alwaysLight
        case .forceDark:
            return Label.alwaysDark
        }
    }
}
*/

internal enum Action {
    
    case delete
    case addPlantLong
    case addPlantShort
    case addReminder
    case itemNotFound
    case reminderKind
    case reminderKindWater
    case reminderKindFertilize
    case reminderKindTrim
    case reminderKindMist
    case reminderKindMove
    case reminderKindOther
    case reminderInterval
    case pauseNotifications
    case reminder
    case reminders
    case notes
    case lastPerformed
    case name
    case photo
    
    private var raw: ActionLocalization {
        switch self {
        case .delete:
            return Action.raw_delete
        case .addPlantLong:
            return Action.raw_addPlantLong
        case .addPlantShort:
            return Action.raw_addPlantShort
        case .addReminder:
            return Action.raw_addReminder
        case .itemNotFound:
            return Action.raw_itemNotFound
        case .reminderKind:
            return Action.raw_reminderKind
        case .reminderKindWater:
            return Action.raw_reminderKindWater
        case .reminderKindFertilize:
            return Action.raw_reminderKindFertilize
        case .reminderKindTrim:
            return Action.raw_reminderKindTrim
        case .reminderKindMist:
            return Action.raw_reminderKindMist
        case .reminderKindMove:
            return Action.raw_reminderKindMove
        case .reminderKindOther:
            return Action.raw_reminderKindOther
        case .reminderInterval:
            return Action.raw_reminderInterval
        case .pauseNotifications:
            return Action.raw_pauseNotifications
        case .reminder:
            return Action.raw_reminder
        case .reminders:
            return Action.raw_reminders
        case .notes:
            return Action.raw_notes
        case .lastPerformed:
            return Action.raw_lastPerformed
        case .name:
            return Action.raw_name
        case .photo:
            return Action.raw_photo
        }
    }
    
    internal func localized(_ bundle: LocalizeBundle) -> ActionLocalization {
        var output = self.raw
        output.title = bundle.localized(key: raw.title)
        output.hint = raw.hint.map { bundle.localized(key: $0) }
        return output
    }
}

extension Action {
    private static let raw_delete: ActionLocalization = {
        .init(title: Verb.delete.rawValue,
              hint:  nil,
              image: nil)
    }()
    private static let raw_addPlantLong: ActionLocalization = {
        .init(title: Verb.addPlant.rawValue,
              hint:  nil,
              image: nil)
    }()
    private static let raw_addPlantShort: ActionLocalization = {
        .init(title: Verb.addGeneric.rawValue,
              hint:  nil,
              image: nil)
    }()
    private static let raw_addReminder: ActionLocalization = {
        .init(title: Verb.addReminder.rawValue,
              hint:  nil,
              image: .image(Symbol.plus.catalog))
    }()
    private static let raw_itemNotFound: ActionLocalization = {
        .init(title: Noun.itemNotFound.rawValue,
              hint:  nil,
              image: .system(Symbol.noContent.rawValue))
    }()
    private static let raw_reminderKind: ActionLocalization = {
        .init(title: Noun.reminderKindShort.rawValue,
              // TODO: Change to verb
              hint:  nil,
              image: nil)
    }()
    private static let raw_reminderKindWater: ActionLocalization = {
        .init(title: Noun.waterShort.rawValue,
              hint:  nil,
              image: nil)
    }()
    private static let raw_reminderKindFertilize: ActionLocalization = {
        .init(title: Noun.fertilizeShort.rawValue,
              hint:  nil,
              image: nil)
    }()
    private static let raw_reminderKindTrim: ActionLocalization = {
        .init(title: Noun.trimShort.rawValue,
              hint:  nil,
              image: nil)
    }()
    private static let raw_reminderKindMist: ActionLocalization = {
        .init(title: Noun.mistShort.rawValue,
              hint:  nil,
              image: nil)
    }()
    private static let raw_reminderKindMove: ActionLocalization = {
        .init(title: Noun.moveShort.rawValue,
              hint:  nil,
              image: nil)
    }()
    private static let raw_reminderKindOther: ActionLocalization = {
        .init(title: Noun.other.rawValue,
              hint:  nil,
              image: nil)
    }()
    private static let raw_reminderInterval: ActionLocalization = {
        .init(title: Noun.remindEvery.rawValue,
              hint:  nil,
              image: nil)
    }()
    private static let raw_pauseNotifications: ActionLocalization = {
        .init(title: Verb.pauseNotifications.rawValue,
              hint:  nil,
              image: nil)
    }()
    private static let raw_reminder: ActionLocalization = {
        .init(title: Noun.reminder.rawValue,
              hint:  nil,
              image: nil)
    }()
    private static let raw_reminders: ActionLocalization = {
        .init(title: Noun.reminders.rawValue,
              hint:  nil,
              image: nil)
    }()
    private static let raw_notes: ActionLocalization = {
        .init(title: Noun.notes.rawValue,
              hint:  nil,
              image: nil)
    }()
    private static let raw_lastPerformed: ActionLocalization = {
        .init(title: Noun.lastPerformed.rawValue,
              hint:  nil,
              image: nil)
    }()
    private static let raw_name: ActionLocalization = {
        .init(title: Noun.name.rawValue,
              hint:  nil,
              image: nil)
    }()
    private static let raw_photo: ActionLocalization = {
        .init(title: Noun.photo.rawValue,
              hint:  nil,
              image: nil)
    }()
}
