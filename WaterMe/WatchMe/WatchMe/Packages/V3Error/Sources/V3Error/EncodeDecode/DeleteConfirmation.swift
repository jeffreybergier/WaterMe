//
//  Created by Jeffrey Bergier on 2022/11/19.
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
import Umbrella
import V3Model

extension DeleteConfirmationError: CodecProtocol {
    
    private static let encoder = PropertyListEncoder()
    private static let decoder = PropertyListDecoder()
    
    public init?(decode: Umbrella.CodableError) {
        guard
            decode.errorDomain == DeleteConfirmationError.errorDomain,
            let data = decode.arbitraryData,
            let error = try? type(of: self).decoder.decode(DeleteConfirmationError.self, from: data)
        else { return nil }
        self = error
    }
    public var encode: Umbrella.CodableError {
        let data = try? type(of: self).encoder.encode(self)
        return .init(domain: type(of: self).errorDomain,
                     code: self.errorCode,
                     arbitraryData: data)
    }
}
