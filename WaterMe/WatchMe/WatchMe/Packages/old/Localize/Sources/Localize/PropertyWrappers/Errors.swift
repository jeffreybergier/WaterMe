//
//  Created by Jeffrey Bergier on 2022/02/27.
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

public struct CameraError {
    public static let title = Phrase.errorPhotoSave
    public static let message = Phrase.errorPhotoChosen
    public static let dismiss = Action.dismiss
}

public struct CameraPermissionError {
    public static let titlePermission = Label.permissionDenied
    public static let titleOther = Label.error
    public static let messageRestricted = Phrase.cameraAccessRestricted
    public static let messageDenied = Phrase.cameraAccessDenied
    public static let messageIncapableCamera = Phrase.deviceCameraNone
    public static let messageIncapableLibrary = Phrase.notImplementedWatchLibrary
    public static let dismiss = Action.dismiss
}

public struct DatumError {
    public static let titleUnsure = Label.error
    public static let titleDelete = Label.errorDeleting
    public static let titleLoad = Label.errorLoading
    public static let titleWrite = Label.errorSaving
    public static let messageWrite = Phrase.errorSaving
    public static let messageLoad = Phrase.errorLoading
    public static let messageDelete = Phrase.errorDeleteLastReminder
    public static let messageMaintenance = Phrase.errorMaintenance
    public static let messageObjectMissing = Phrase.errorAlreadyDeleted
    public static let buttonOpenSettings = Action.openSettings
}

public struct DeleteError {
    public static let message = Phrase.confirmDelete
    public static let actionDelete = Action.delete
    public static let actionCancel = Action.dontDelete
}
