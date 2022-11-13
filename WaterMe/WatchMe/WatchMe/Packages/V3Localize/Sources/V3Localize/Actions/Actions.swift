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
 
 extension V3Model.Reminder.Kind {
     internal var localizedShort: LocalizationKey {
         switch self {
         case .water:
             return Label.waterShort
         case .fertilize:
             return Label.fertilizeShort
         case .trim:
             return Label.trimShort
         case .mist:
             return Label.mistShort
         case .move:
             return Label.moveShort
         case .other:
             return Label.other
         }
     }

     internal var localizedLong: LocalizationKey {
         switch self {
         case .water:
             return Label.waterLong
         case .fertilize:
             return Label.fertilizeLong
         case .trim:
             return Label.trimLong
         case .mist:
             return Label.mistLong
         case .move:
             return Label.moveLong
         case .other:
             return Label.other
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
    case addPlant
    case noContent
    
    internal func localized(_ bundle: LocalizeBundle) -> ActionLocalization {
        var output = self.raw
        output.title = bundle.localized(key: raw.title)
        output.hint = raw.hint.map { bundle.localized(key: $0) }
        return output
    }
    
    private var raw: ActionLocalization {
        switch self {
        case .delete:
            return Action.raw_delete
        case .addPlant:
            return Action.raw_addPlant
        case .noContent:
            return Action.raw_noContent
        }
    }
}

extension Action {
    private static let raw_delete: ActionLocalization = {
        .init(title: Verb.delete.rawValue,
              hint:  nil,
              image: nil)
    }()
    private static let raw_addPlant: ActionLocalization = {
        .init(title: Verb.addPlant.rawValue,
              hint:  nil,
              image: nil)
    }()
    private static let raw_noContent: ActionLocalization = {
        .init(title: Noun.emptyString.rawValue,
              hint:  nil,
              image: .system(Symbol.noContent.rawValue))
    }()
}
