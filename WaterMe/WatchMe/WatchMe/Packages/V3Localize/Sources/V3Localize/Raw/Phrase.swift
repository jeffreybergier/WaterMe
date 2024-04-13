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

internal enum Phrase: LocalizationKey {

    case placeholderTrim            = "Trim the leaves and throw out the clippings."
    case placeholderMove            = "Other side of the yard."
    case chooseIconMenuTitle        = "View the current photo or choose a new photo or emoji for your plant."
    case errorPhotoSave             = "Error saving photo"
    case errorPhotoChosen           = "The selected photo couldn’t be saved. Please take a different photo or choose an emoji."
    case cameraAccessRestricted     = "WaterMe cannot access your camera. This feature has been restricted by this device’s administrator."
    case cameraAccessDenied         = "WaterMe cannot access your camera. You can grant access in Settings"
    case deviceCameraNone           = "This device does not have a camera."
    case notImplementedWatchLibrary = "The Apple Watch version of WaterMe does not support choosing from Photo Library yet."
    case errorSaving                = "Error saving changes. Check to make sure there is free space available on this device."
    case errorLoading               = "Error loading save file. Check to make sure there is free space available on this device."
    case errorDeleteLastReminder    = "Unable to delete this reminder because its the only reminder for this plant. Each plant must have at least one reminder."
    case errorMaintenance           = "Error performing maintenance. Check to make sure there is free space available on this device."
    case errorAlreadyDeleted        = "Unable to save changes because the item was deleted. Possibly from another device."
    case errorUnknown               = "An unknown error occurred."
    case confirmDelete              = "Are you sure you want to delete this?"
    case youreAllSet                = "You're All Set"
    case watch_syncInitialize       = "Waiting for first sync"
    static func markXAsDoneMarkdown(_ count: Int) -> String.LocalizationValue { "Mark ^[\(count) Reminder](inflect: true) as Done" }
}
