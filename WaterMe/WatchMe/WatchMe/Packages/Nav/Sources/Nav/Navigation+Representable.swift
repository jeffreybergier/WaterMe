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

import Foundation

extension Navigation.State: RawRepresentable {
    public init(rawValue: String) {
        guard
            let data = rawValue.data(using: .utf8),
            let result = try? PropertyListDecoder().decode(Navigation.State.self, from: data)
        else {
            self = .rootアList
            return
        }
        self = result
    }
    public var rawValue: String {
        guard
            let data = try? PropertyListEncoder().encode(self),
            let result = String(data: data, encoding: .utf8)
        else { return "" }
        return result
    }
}
