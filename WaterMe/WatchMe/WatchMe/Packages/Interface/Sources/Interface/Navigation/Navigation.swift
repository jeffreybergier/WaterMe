//
//  Created by Jeffrey Bergier on 2022/01/01.
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

import SwiftUI
import Datum

internal enum Navigation: Codable {
    case list(List)
}

extension Navigation {
    internal enum List: Codable {
        case none
        case menu(MenuInput)
        case watering
        case summary(Reminder.アイディ)
        case reminder(Reminder.アイディ)
        case vessel(VesselEditInput)
        case settings
        case error
    }
}

extension Navigation.List {
    internal struct MenuInput: Codable {
        internal var reminder: Reminder.アイディ
        internal var vessel: Vessel.アイディ
        init(_ input: Binding<Reminder>) {
            self.reminder = input.wrappedValue.id
            self.vessel = input.wrappedValue.vesselID!
        }
        init(_ input: Reminder) {
            self.reminder = input.id
            self.vessel = input.vesselID!
        }
    }
}

extension Navigation.List {
    internal struct VesselEditInput: Codable, Identifiable {
        internal var id: Vessel.アイディ
        internal var presentation: Presentation
        internal init(_ id: Vessel.アイディ, _ presentation: Presentation = .none) {
            self.id = id
            self.presentation = presentation
        }
        
        internal enum Presentation: Codable {
            case none
            case reminder(Reminder.アイディ)
            case error
        }
    }
}
