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

public enum DeleteRequestError: CustomNSError, CodableErrorConvertible, Codable {
    
    static public var errorDomain = "com.saturdayapps.WaterMe.model"
    public var errorCode: Int { 1001 }
    
    case vessel(Vessel.Identifier)
    case reminder(Reminder.Identifier)
    
    public init?(decode: Umbrella.CodableError) {
        guard let data = decode.arbitraryData else { return nil }
        // TODO: Uh, figure out why the types don't decode securely
        if let id = try? PropertyListDecoder().decode(Vessel.Identifier.self, from: data) {
            self = .vessel(id)
            return
        }
        if let id = try? PropertyListDecoder().decode(Reminder.Identifier.self, from: data) {
            self = .reminder(id)
            return
        }
        assertionFailure()
        return nil
    }
    
    public var encode: Umbrella.CodableError {
        var output = CodableError(self)
        switch self {
        case .vessel(let id):
            output.arbitraryData = try? PropertyListEncoder().encode(id)
        case .reminder(let id):
            output.arbitraryData = try? PropertyListEncoder().encode(id)
        }
        assert(output.arbitraryData != nil)
        return output
    }
    
    public var vesselID: Vessel.Identifier? {
        guard case .vessel(let id) = self else { return nil }
        return id
    }
    
    public var reminderID: Reminder.Identifier? {
        guard case .reminder(let id) = self else { return nil }
        return id
    }
}
