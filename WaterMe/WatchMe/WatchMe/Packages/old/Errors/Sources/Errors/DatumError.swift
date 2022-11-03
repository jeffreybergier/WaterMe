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

import Umbrella
import Datum
import Localize

extension Datum.Error: UserFacingError {

    public var title: String {
        switch self {
        case .load, .read, .objectMissing:
            return DatumError.titleLoad
        case .write:
            return DatumError.titleWrite
        case .cannotDeleteLastReminder:
            return DatumError.titleDelete
        case .maintenanceOneTrueVesselShare,
                .maintenanceMassageAllEntries,
                .maintenanceFixDates,
                .maintenanceDeleteOrphanedReminders,
                .maintenanceFixOrphanedVessels,
                .maintenanceContextMismatch:
            return DatumError.titleUnsure
        }
    }
    public var message: String {
        switch self {
        case .load, .read:
            return DatumError.messageLoad
        case .write:
            return DatumError.messageWrite
        case .objectMissing:
            return DatumError.messageObjectMissing
        case .cannotDeleteLastReminder:
            return DatumError.messageDelete
        case .maintenanceOneTrueVesselShare,
                .maintenanceMassageAllEntries,
                .maintenanceFixDates,
                .maintenanceDeleteOrphanedReminders,
                .maintenanceFixOrphanedVessels,
                .maintenanceContextMismatch:
            return DatumError.messageMaintenance
        }
    }
    public var isCritical: Bool {
        if case .cannotDeleteLastReminder = self {
            return false
        }
        return true
    }

    public var options: [RecoveryOption] {
        if case .cannotDeleteLastReminder = self {
            return []
        }
        // TODO: Make this button work
        return [.init(title: DatumError.buttonOpenSettings, perform: {})]
    }
}
