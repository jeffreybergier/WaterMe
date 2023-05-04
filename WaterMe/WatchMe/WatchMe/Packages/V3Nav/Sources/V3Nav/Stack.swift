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

extension Nav.Value {
    public struct Stack {
        
        public var path: NavigationPath = .init()
        
        internal init() {}
        
        public mutating func pop() {
            self.path.removeLast()
        }
        
        public mutating func main(_ share: Share.Identifier) {
            self.path.append(Nav.Special(share))
        }
        
        public mutating func list(_ share: Share.Identifier) {
            self.path.append(Nav.List(share))
        }
        
        public mutating func list(_ vessel: Vessel.Identifier) {
            self.path.append(Nav.List(vessel))
        }
        
        public mutating func view(_ reminder: Reminder.Identifier) {
            self.path.append(Nav.View(reminder))
        }
        
        public mutating func edit(_ vessel: Vessel.Identifier) {
            self.path.append(Nav.Edit(vessel))
        }
        
        public mutating func edit(_ reminder: Reminder.Identifier) {
            self.path.append(Nav.Edit(reminder))
        }
        public mutating func picker(kind: Nav.PickerKind, for vessel: Vessel.Identifier) {
            self.path.append(Nav.Picker(kind: kind, for: vessel))
        }
        public mutating func wateringAnimation() {
            self.path.append(Nav.WateringAnimation())
        }
    }
}

extension Nav {
    public struct Special<T: Codable & Hashable>: Codable, Hashable {
        public var id: T
        public init(_ id: T) {
            self.id = id
        }
    }
    
    public struct List<T: Codable & Hashable>: Codable, Hashable {
        public var id: T
        public init(_ id: T) {
            self.id = id
        }
    }
    
    public struct View<T: Codable & Hashable>: Codable, Hashable {
        public var id: T
        public init(_ id: T) {
            self.id = id
        }
    }
    
    public struct Edit<T: Codable & Hashable>: Codable, Hashable {
        public var id: T
        public init(_ id: T) {
            self.id = id
        }
    }
    
    public struct WateringAnimation: Codable, Hashable {
        public init() { }
    }
    
    public enum PickerKind: Codable, Hashable {
        case emoji, camera, library, viewPhoto
    }
    
    public struct Picker<T: Codable & Hashable>: Codable, Hashable {
        public var id: T
        public var kind: PickerKind
        public init(kind: PickerKind, for id: T) {
            self.id = id
            self.kind = kind
        }
    }
}

extension Nav.Value.Stack: Codable {
    public enum CodingKeys: String, CodingKey {
        case path
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.path.codable, forKey: .path)
    }
    public init(from decoder: Decoder) throws {
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
