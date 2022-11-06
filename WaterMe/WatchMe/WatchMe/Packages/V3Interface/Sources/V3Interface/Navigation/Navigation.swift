//
//  Created by Jeffrey Bergier on 2022/11/06.
//
//  Copyright © 2022 Saturday Apps.
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
import Umbrella
import V3Model

@propertyWrapper
internal struct Nav: DynamicProperty {
    
    internal struct Value {
        internal var path: NavigationPath
        internal init() {
            self.path = .init()
        }
        internal mutating func pop() {
            self.path.removeLast()
        }
        internal mutating func list(_ vessel: Vessel.Identifier) {
            self.path.append(vessel)
        }
        internal mutating func view(_ reminder: Reminder.Identifier) {
            self.path.append(reminder)
        }
        internal mutating func edit(_ vessel: Vessel.Identifier) {
            self.path.append(vessel)
        }
        internal mutating func edit(_ reminder: Reminder.Identifier) {
            self.path.append(reminder)
        }
    }
    
    @JSBSceneStorage("com.saturdayapps.waterme.navigation")
    private var storage: Value = .init()
    
    internal init() {}
    
    internal var wrappedValue: Value {
        get {
            self.storage
        }
        nonmutating set {
            self.storage = newValue
            #if DEBUG // TODO: Remove this
            dump(newValue.path)
            #endif
        }
    }
    
    internal var projectedValue: Binding<Value> {
        Binding {
            self.wrappedValue
        } set: {
            self.wrappedValue = $0
        }
    }
}

extension Nav.Value: Codable {
    internal enum CodingKeys: String, CodingKey {
        case path
    }
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.path.codable, forKey: .path)
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        guard let rep = try? values.decode(
            NavigationPath.CodableRepresentation.self,
            forKey: .path
        ) else {
            self.path = .init()
            return
        }
        self.path = .init(rep)
    }
}
