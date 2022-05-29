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

internal struct Phrase {

    internal static let placeholderTrim: LocalizationKey = "Trim the leaves and throw out the clippings."
    internal static let placeholderMove: LocalizationKey = "Other side of the yard."
    internal static let chooseIconMenuTitle: LocalizationKey = "View the current photo or choose a new photo or emoji for your plant."
    internal static let chooseAnEmoji: LocalizationKey = "Choose an Emoji"
    internal static let errorPhotoSave: LocalizationKey = "Error saving photo"
    internal static let errorPhotoChosen: LocalizationKey = "The selected photo couldn’t be saved. Please take a different photo or choose an emoji."
    internal static let cameraAccessRestricted: LocalizationKey = "WaterMe cannot access your camera. This feature has been restricted by this device’s administrator."
    internal static let cameraAccessDenied: LocalizationKey = "WaterMe cannot access your camera. You can grant access in Settings"
    internal static let deviceCameraNone: LocalizationKey = "This device does not have a camera."
    internal static let notImplementedWatchLibrary: LocalizationKey = "The Apple Watch version of WaterMe does not support choosing from Photo Library yet."
    internal static let errorSaving: LocalizationKey = "Error saving changes. Check to make sure there is free space available on this device."
    internal static let errorLoading: LocalizationKey = "Error loading save file. Check to make sure there is free space available on this device."
    internal static let errorDeleteLastReminder: LocalizationKey = "Unable to delete this reminder because its the only reminder for this plant. Each plant must have at least one reminder."
    internal static let errorMaintenance: LocalizationKey = "Error performing maintenance. Check to make sure there is free space available on this device."
    internal static let errorAlreadyDeleted: LocalizationKey = "Unable to save changes because the item was deleted. Possibly from another device."
    internal static let confirmDelete: LocalizationKey = "Are you sure you want to delete this?"

}
