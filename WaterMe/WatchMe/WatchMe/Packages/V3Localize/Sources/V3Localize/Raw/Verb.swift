//
//  Created by Jeffrey Bergier on 2022/02/18.
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

internal enum Verb: LocalizationKey {
    case addGeneric         = "Action.Add Generic"
    case addPlant           = "Action.Add Plant"
    case addReminder        = "Action.Add Reminder"
    case dismiss            = "Action.Dismiss"
    case editPlant          = "Action.Edit Plant"
    case editPhoto          = "Action.Edit Photo"
    case editReminder       = "Action.Edit Reminder"
    case markDoneGeneric    = "Action.Mark as Done"
    case markDoneReminder   = "Action.Mark Reminder as Done"
    case delete             = "Action.Delete"
    case dontDelete         = "Action.Don't Delete"
    case done               = "Action.Done"
    case viewCurrentPhoto   = "Action.View Current Photo"
    case cancel             = "Action.Cancel"
    case emoji              = "Action.Emoji"
    case camera             = "Action.Camera"
    case cameraLock         = "Action.Camera 🔒"
    case photos             = "Action.Photos"
    case photosLock         = "Action.Photos 🔒"
    case pauseNotifications = "Action.Pause Notifications"
    case pause              = "Action.Pause"
    case openSettings       = "Action.Open Settings"
    case settings           = "Action.Settings"
    case syncIdle           = "Action.iCloud Sync Complete"
    case syncError          = "Action.iCloud Sync Error"
    case syncUnavailable    = "Action.iCloud Sync Unavailable"
    case syncSyncing        = "Action.Syncing with iCloud…"
}
