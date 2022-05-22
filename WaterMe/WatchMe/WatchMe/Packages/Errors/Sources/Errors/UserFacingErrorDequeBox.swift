//
//  Created by Jeffrey Bergier on 2022/02/05.
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
import Umbrella
import Collections

internal struct UserFacingErrorDequeBox: Codable, RawRepresentable {
    
    internal var value: Deque<UserFacingError> = []
    
    internal init() {}
    
    internal enum CodingKeys: String, CodingKey {
         case value
    }
    
    internal func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        let copy = self.value.map { UserFacingErrorBox($0) }
        try c.encode(copy, forKey: .value)
    }
    
    internal init(from decoder: Decoder) throws {
        let d = try decoder.container(keyedBy: CodingKeys.self)
        let copy = try d.decode(Array<UserFacingErrorBox>.self, forKey: .value)
        self.value = Deque(copy.compactMap { $0.error })
    }
    
    internal init?(rawValue: String) {
        guard let data = Data(base64Encoded: rawValue),
        let d = try? PropertyListDecoder().decode(UserFacingErrorDequeBox.self, from: data)
        else { return nil }
        self.value = d.value
    }
    
    internal var rawValue: String {
        (try? PropertyListEncoder().encode(self))?.base64EncodedString() ?? ""
    }
}
