//
//  SelfContainedImagePickerController.swift
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

import CropViewController
import MobileCoreServices
import Photos
import UIKit

class ImagePickerCropperViewController: UIImagePickerController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    class var cameraPermission: AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
    }
    
    private class func newVC(completionHandler: @escaping (UIImage?, UIViewController) -> Void) -> ImagePickerCropperViewController {
        let vc = ImagePickerCropperViewController()
        vc.completionHandler = completionHandler
        vc.modalPresentationStyle = .overFullScreen
        vc.imageExportPreset = .compatible
        vc.delegate = vc
        vc.allowsEditing = false
        vc.mediaTypes = [kUTTypeImage as String]
        return vc
    }
    
    class func newPhotosVC(completionHandler: @escaping (UIImage?, UIViewController) -> Void) -> UIViewController {
        let vc = self.newVC(completionHandler: completionHandler)
        vc.sourceType = .photoLibrary
        return vc
    }
    
    class func newCameraVC(completionHandler: @escaping (UIImage?, UIViewController) -> Void) -> UIViewController {
        let vc = self.newVC(completionHandler: completionHandler)
        vc.sourceType = .camera
        return vc
    }
    
    var completionHandler: ((UIImage?, UIViewController) -> Void)?
    private var permissionCheckTimer: Timer?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard self.permissionCheckTimer == nil else { return }
        self.permissionCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            func invalidateTimer() {
                timer.invalidate()
                self.permissionCheckTimer?.invalidate()
                self.permissionCheckTimer = nil
            }
            switch self.sourceType {
            case .camera:
                switch type(of: self).cameraPermission {
                case .authorized:
                    invalidateTimer()
                case .restricted, .denied:
                    invalidateTimer()
                    self.completionHandler?(nil, self)
                case .notDetermined:
                    fallthrough
                @unknown default:
                    break // do nothing. the user needs to pick
                }
            case .photoLibrary, .savedPhotosAlbum:
                invalidateTimer() // iOS 11 makes photos permission no longer needed for UIImagePickerController
            @unknown default:
                // in the case we don't know whats happening,
                // just disable the timer and hope it all works out.
                invalidateTimer()
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let original = info[.originalImage] as? UIImage
        guard let image = original else { self.completionHandler?(nil, picker); return; }
        let crop = CropViewController(croppingStyle: .default, image: image)
        crop.delegate = self
        crop.style_waterMe()
        self.present(crop, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.completionHandler?(nil, self)
    }
    
    deinit {
        self.permissionCheckTimer?.invalidate()
    }
}

extension CropViewController {
    func style_waterMe() {
        // hide the aspect ratio button
        // lock the aspect ratio to square
        self.aspectRatioPickerButtonHidden = true
        self.aspectRatioPreset = .presetSquare
        self.aspectRatioLockEnabled = true
        self.resetAspectRatioEnabled = true

        // configure the buttons to have the right tintcolor
        self.toolbar.doneIconButton.setTitleColor(nil, for: .normal)
        self.toolbar.doneTextButton.setTitleColor(nil, for: .normal)
        self.toolbar.cancelIconButton.setTitleColor(nil, for: .normal)
        self.toolbar.cancelIconButton.setTitleColor(nil, for: .normal)
        self.toolbar.doneIconButton.tintColor = Color.tint
        self.toolbar.doneTextButton.tintColor = Color.tint
        self.toolbar.cancelIconButton.tintColor = Color.delete
        self.toolbar.cancelIconButton.tintColor = Color.delete
    }
}

extension ImagePickerCropperViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismissNoForReal() {
            self.completionHandler?(image, self)
        }
    }

    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismissNoForReal() {
            self.completionHandler?(nil, self)
        }
    }
}
