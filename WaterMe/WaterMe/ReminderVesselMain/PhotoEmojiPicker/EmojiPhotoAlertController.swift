//
//  EmojiPhotoAlertController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/3/17.
//  Copyright © 2017 Saturday Apps.
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

import Photos
import UIKit

extension UIAlertController {

    enum EmojiPhotoChoice {
        case photos, camera, emoji, viewCurrentPhoto, error(UIViewController)
    }

    class var cameraLocalizedString: String {
        switch ImagePickerCropperViewController.cameraPermission {
        case .authorized, .notDetermined:
            return UIAlertController.LocalizedString.buttonTitleCamera
        case .denied, .restricted:
            fallthrough
        @unknown default:
            return UIAlertController.LocalizedString.buttonTitleCameraLocked
        }
    }

    class func emojiPhotoActionSheet(withAlreadyChosenImage alreadyChosenImage: Bool,
                                     completionHandler: @escaping (EmojiPhotoChoice) -> Void) -> UIAlertController
    {
        let message = alreadyChosenImage ?
            UIAlertController.LocalizedString.titleNewEmojiPhotoExistingPhoto :
            UIAlertController.LocalizedString.titleNewEmojiPhoto
        let alertVC = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        let emoji = UIAlertAction(title: UIAlertController.LocalizedString.buttonTitleEmoji,
                                  style: .default) { _ in completionHandler(.emoji) }
        let photo = UIAlertAction(title: UIAlertController.LocalizedString.buttonTitlePhotos,
                                  style: .default) { _ in completionHandler(.photos) }
        let cancel = UIAlertAction(title: UIAlertController.LocalizedString.buttonTitleCancel,
                                   style: .cancel, handler: nil)

        alertVC.addAction(emoji)
        let front = UIImagePickerController.isCameraDeviceAvailable(.front)
        let rear = UIImagePickerController.isCameraDeviceAvailable(.rear)
        if front || rear {
            let camera = UIAlertAction(title: self.cameraLocalizedString, style: .default) { _ in
                switch ImagePickerCropperViewController.cameraPermission {
                case .restricted:
                    let errorVC = self.cameraRestrictedAlert()
                    completionHandler(.error(errorVC))
                case .denied:
                    let errorVC = self.cameraDeniedAlert()
                    completionHandler(.error(errorVC))
                case .authorized, .notDetermined:
                    fallthrough
                @unknown default:
                    completionHandler(.camera)
                }
            }
            alertVC.addAction(camera)
        }
        alertVC.addAction(photo)
        if alreadyChosenImage {
            let photoViewer = UIAlertAction(title: UIAlertController.LocalizedString.buttonTitleViewPhoto,
                                            style: .default) { _ in completionHandler(.viewCurrentPhoto) }
            alertVC.addAction(photoViewer)
        }
        alertVC.addAction(cancel)
        return alertVC
    }

    class func cameraRestrictedAlert() -> UIAlertController {
        let alertVC = UIAlertController(title: ReminderVesselEditViewController.LocalizedString.alertTitleCameraRestricted,
                                        message: ReminderVesselEditViewController.LocalizedString.alertBodyCameraRestricted,
                                        preferredStyle: .alert)
        let cancel = UIAlertAction(title: LocalizedString.buttonTitleCancel, style: .cancel, handler: nil)
        alertVC.addAction(cancel)
        return alertVC
    }

    class func cameraDeniedAlert() -> UIAlertController {
        let alertVC = UIAlertController(title: ReminderVesselEditViewController.LocalizedString.alertTitlePermissionDenied,
                                        message: ReminderVesselEditViewController.LocalizedString.alertBodyCameraDenied,
                                        preferredStyle: .alert)
        let settings = UIAlertAction(title: SettingsMainViewController.LocalizedString.cellTitleOpenSettings,
                                     style: .default)
        { _ in
            UIApplication.shared.openAppSettings(completion: nil)
        }
        let cancel = UIAlertAction(title: LocalizedString.buttonTitleCancel, style: .cancel, handler: nil)
        alertVC.addAction(settings)
        alertVC.addAction(cancel)
        return alertVC
    }
}
