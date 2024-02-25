//
//  Created by Jeffrey Bergier on 2022/11/20.
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

import Umbrella
import V3Datum

extension V3Datum.Error: UserFacingError {
    public var title: Umbrella.LocalizationKey {
        switch self {
        case .load:
            return Noun.errorLoading.rawValue
        case .write:
            return Noun.errorSaving.rawValue
        case .cannotDeleteLastReminder:
            return Noun.errorDeleting.rawValue
        case .objectMissing,
             .maintenanceOneTrueVesselShare,
             .maintenanceMassageAllEntries,
             .maintenanceFixDates,
             .maintenanceDeleteOrphanedReminders,
             .maintenanceFixOrphanedVessels,
             .maintenanceContextMismatch:
            return Noun.error.rawValue
        }
    }
    public var message: Umbrella.LocalizationKey {
        switch self {
        case .load:
            return Phrase.errorLoading.rawValue
        case .write:
            return Phrase.errorSaving.rawValue
        case .cannotDeleteLastReminder:
            return Phrase.errorDeleteLastReminder.rawValue
        case .objectMissing:
            return Phrase.errorAlreadyDeleted.rawValue
        case .maintenanceOneTrueVesselShare,
             .maintenanceMassageAllEntries,
             .maintenanceFixDates,
             .maintenanceDeleteOrphanedReminders,
             .maintenanceFixOrphanedVessels,
             .maintenanceContextMismatch:
            return Phrase.errorMaintenance.rawValue
        }
    }
    public var dismissTitle: Umbrella.LocalizationKey {
        Verb.dismiss.rawValue
    }
    public var isCritical: Bool {
        false
    }
    public var options: [RecoveryOption] {
        switch self {
        case .load,
             .write,
             .maintenanceOneTrueVesselShare,
             .maintenanceMassageAllEntries,
             .maintenanceFixDates,
             .maintenanceDeleteOrphanedReminders,
             .maintenanceFixOrphanedVessels:
            return openSettings
        case .maintenanceContextMismatch,
             .objectMissing,
             .cannotDeleteLastReminder:
            return []
        }
    }
}

#if os(iOS)

import UIKit

internal let openSettings: [RecoveryOption] = {
    [
        .init(title: Verb.openSettings.rawValue) {
            let url = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(url)
        }
    ]
}()

#else

// TODO: Change out of space strings for WatchOS
// On WatchOS is there anything the user can do if there is a write error?
internal let openSettings: [RecoveryOption] = {
    []
}()

#endif
