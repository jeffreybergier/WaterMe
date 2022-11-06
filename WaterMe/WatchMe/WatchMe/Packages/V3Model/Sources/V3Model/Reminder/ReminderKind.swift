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

import Foundation

extension Reminder {
    
    public enum Sort: String, Codable, Hashable, CaseIterable, Identifiable {
        case nextPerformDate, interval, kind, note
        public var id: String { self.rawValue }
    }
    
    public enum Kind: String, Codable, Hashable, CaseIterable, Identifiable {
        case water     = "kReminderKindCaseWaterValue"
        case fertilize = "kReminderKindCaseFertilizeValue"
        case trim      = "kReminderKindCaseTrimValue"
        case mist      = "kReminderKindCaseMistValue"
        case move      = "kReminderKindCaseMoveValue"
        case other     = "kReminderKindCaseOtherValue"
        public var id: String { self.rawValue }
    }
    
    public enum Filter: Codable, Hashable {
        case none, all, share(Share.Identifier)
    }
    
    public enum Section: Int, Codable, Hashable, CaseIterable, Identifiable {
        case late, today, tomorrow, thisWeek, later, disabled
        public var id: Int { self.rawValue }
        
        public var dateInterval: DateInterval {
            switch self {
            case .late:
                return ReminderDateCalculator.late()
            case .today:
                return ReminderDateCalculator.today()
            case .tomorrow:
                return ReminderDateCalculator.tomorrow()
            case .thisWeek:
                return ReminderDateCalculator.thisWeek()
            case .later:
                return ReminderDateCalculator.later()
            case .disabled:
                fatalError("DISABLED does not have a date range")
            }
        }
    }
}
