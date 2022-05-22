//
//  Created by Jeffrey Bergier on 2022/02/11.
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

public struct CompleteDictionary<Key: Hashable & CaseIterable, Value>: ExpressibleByDictionaryLiteral {
    private var data: [Key:Value] = [:]
    public init(_ input: (Key) -> Value) {
        for key in Key.allCases {
            self.data[key] = input(key)
        }
    }
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.data = Dictionary(uniqueKeysWithValues: elements)
        precondition(self.data.count == Key.allCases.count)
    }
    public subscript(key: Key) -> Value {
        self.value(for: key)
    }
    public func value(for key: Key) -> Value {
        self.data[key]!
    }
}
