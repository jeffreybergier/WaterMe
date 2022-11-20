//
//  Created by Jeffrey Bergier on 2022/01/03.
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
import Umbrella

public enum Error: Int, CustomNSError {

    static public var errorDomain = "com.saturdayapps.WaterMe.datum"
    public var errorCode: Int { return self.rawValue }

    case load
    case write
    case read
    case objectMissing
    case cannotDeleteLastReminder
    case maintenanceOneTrueVesselShare
    case maintenanceMassageAllEntries
    case maintenanceFixDates
    case maintenanceDeleteOrphanedReminders
    case maintenanceFixOrphanedVessels
    case maintenanceContextMismatch
}

extension Error: CodableErrorConvertible {
    public init?(decode: CodableError) {
        guard decode.errorDomain == V3Datum.Error.errorDomain else { return nil }
        self.init(rawValue: decode.errorCode)
    }
    public var encode: CodableError {
        .init(self)
    }
}
