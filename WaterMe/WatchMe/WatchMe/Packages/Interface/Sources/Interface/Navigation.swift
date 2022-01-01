//
//  Created by Jeffrey Bergier on 2021/12/30.
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

// TODO: Move this
func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}

internal enum Navigation: RawRepresentable, Codable {
    case list(ReminderList)
    // MARK: RawRepresentable
    init(rawValue: String) {
        guard
            let data = rawValue.data(using: .utf8),
            let result = try? PropertyListDecoder().decode(Navigation.self, from: data)
        else { self = .list(.none); return; }
        self = result
    }
    var rawValue: String {
        guard
            let data = try? PropertyListEncoder().encode(self),
            let result = String(data: data, encoding: .utf8)
        else { return "" }
        return result
    }
    
    internal enum ReminderList: RawRepresentable, Codable {
        case none
        case menu(String)
        case watering
        case summary(String)
        case reminder(String)
        case plant(String)
        case settings
        case error
        
        // MARK: RawRepresentable
        init(rawValue: String) {
            guard
                let data = rawValue.data(using: .utf8),
                let result = try? PropertyListDecoder().decode(ReminderList.self, from: data)
            else { self = .none; return; }
            self = result
        }
        var rawValue: String {
            guard
                let data = try? PropertyListEncoder().encode(self),
                let result = String(data: data, encoding: .utf8)
            else { return "" }
            return result
        }
    }
}

@propertyWrapper
internal struct Nav: DynamicProperty {

    @SceneStorage("Navigation") private var nav: Navigation = .list(.none)

    internal var wrappedValue: Navigation {
        get { self.nav }
        nonmutating set { self.nav = newValue }
    }
    
    internal var projectedValue: Binding<Navigation> {
        self.$nav
    }
}
