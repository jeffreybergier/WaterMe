//
//  ReminderVesselEditViewController+ReminderVesselEditTableViewControllerDelegate.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 10/11/18.
//  Copyright © 2018 Saturday Apps.
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

import Datum
import IntentsUI
import UIKit

extension ReminderVesselEditViewController: ReminderVesselEditTableViewControllerDelegate {

    func userChosePhotoChange(controller: ReminderVesselEditTableViewController?,
                              sender: PopoverSender)
    {
        self.view.endEditing(false)
        let imageAlreadyChosen = self.vesselResult?.value?.icon?.image != nil
        let vc = UIAlertController.emojiPhotoActionSheet(withAlreadyChosenImage: imageAlreadyChosen)
        { choice in
            switch choice {
            case .camera:
                let vc = ImagePickerCropperViewController.newCameraVC() { image, vc in
                    vc.dismissNoForReal()
                    guard let image = image else { return }
                    self.updateIcon(ReminderVesselIcon(rawImage: image))
                }
                self.present(vc, animated: true, completion: nil)
            case .photos:
                let vc = ImagePickerCropperViewController.newPhotosVC() { image, vc in
                    vc.dismissNoForReal()
                    guard let image = image else { return }
                    self.updateIcon(ReminderVesselIcon(rawImage: image))
                }
                self.present(vc, animated: true, completion: nil)
            case .emoji:
                let vc = EmojiPickerViewController.newVC() { emoji, vc in
                    vc.dismissNoForReal()
                    guard let emoji = emoji else { return }
                    self.updateIcon(.emoji(emoji))
                }
                self.present(vc, animated: true, completion: nil)
            case .viewCurrentPhoto:
                guard let image = self.vesselResult?.value?.icon?.image else { return }
                let config = DismissHandlingImageViewerConfiguration(image: image, completion: { vc in
                    vc.dismissNoForReal()
                })
                let vc = DismissHandlingImageViewerController(configuration: config)
                self.present(vc, animated: true, completion: nil)
            case .error(let errorVC):
                self.present(errorVC, animated: true, completion: nil)
            }
        }
        switch sender {
        case .left(let (sender, location)):
            vc.popoverPresentationController?.sourceView = sender
            vc.popoverPresentationController?.sourceRect = sender.bounds.rect(with: location)
        case .right(let sender):
            vc.popoverPresentationController?.barButtonItem = sender
        }
        self.present(vc, animated: true, completion: nil)
    }

    func userChangedName(to newName: String, controller: ReminderVesselEditTableViewController?) {
        guard let vessel = self.vesselResult?.value, let basicRC = self.basicRC else {
            assertionFailure("Missing ReminderVessel or Realm Controller")
            return
        }
        self.notificationToken?.invalidate() // stop the update notifications from causing the tableview to reload
        let updateResult = basicRC.update(displayName: newName, icon: nil, in: vessel)
        switch updateResult {
        case .failure(let error):
            UIAlertController.presentAlertVC(for: error, over: self) { _ in
                self.completionHandler?(self)
            }
        case .success:
            self.startNotifications()
            // Item changed outside of the change block, time to dirty
            self.userDirtiedUserActivity()
        }
    }

    func userChoseAddReminder(controller: ReminderVesselEditTableViewController?) {
        self.view.endEditing(false)
        guard let vessel = self.vesselResult?.value else {
            assertionFailure("Missing ReminderVessel")
            return
        }
        let addReminderVC = ReminderEditViewController.newVC(basicController: basicRC, purpose: .new(vessel)) { vc in
            vc.dismissNoForReal()
        }
        self.present(addReminderVC, animated: true, completion: nil)
    }

    func userChose(reminder: Reminder,
                   deselectRowAnimated: ((Bool) -> Void)?,
                   controller: ReminderVesselEditTableViewController?)
    {
        self.view.endEditing(false)
        let editReminderVC = ReminderEditViewController.newVC(basicController: basicRC,
                                                              purpose: .existing(reminder))
        { vc in
            vc.dismissNoForReal(completion: { deselectRowAnimated?(true) })
        }
        self.present(editReminderVC, animated: true, completion: nil)
    }

    func userChose(siriShortcut: ReminderVesselEditTableViewController.SiriShortcut,
                   deselectRowAnimated: ((Bool) -> Void)?,
                   controller: ReminderVesselEditTableViewController?)
    {
        guard #available(iOS 12.0, *) else {
            let vc = UIAlertController(localizedSiriShortcutsUnavailableAlertWithCompletionHandler: {
                deselectRowAnimated?(true)
            })
            self.present(vc, animated: true, completion: nil)
            return
        }
        guard
            let activity = self.userActivity,
            activity.activityType == RawUserActivity.editReminderVessel.rawValue
            else {
                assertionFailure("Unexpected User Activity")
                return
        }
        let shortcut = INShortcut(userActivity: activity)
        let vc = ClosureDelegatingAddVoiceShortcutViewController(shortcut: shortcut)
        vc.completionHandler = { vc, result in
            vc.dismissNoForReal() {
                deselectRowAnimated?(true)
                guard case .failure(let error) = result else { return }
                UIAlertController.presentAlertVC(for: error, over: self)
            }
        }
        self.present(vc, animated: true, completion: nil)
    }

    func userDeleted(reminder: Reminder,
                     controller: ReminderVesselEditTableViewController?) -> Bool
    {
        self.view.endEditing(false)
        guard let basicRC = self.basicRC else {
            assertionFailure("Missing Realm Controller.")
            return false
        }
        let deleteResult = basicRC.delete(reminder: reminder)
        switch deleteResult {
        case .success:
            return true
        case .failure(let error):
            UIAlertController.presentAlertVC(for: error, over: self)
            return false
        }
    }

    func userToggled(reminder: Reminder,
                     controller: ReminderVesselEditTableViewController?) -> Bool {
        self.view.endEditing(false)
        guard let basicRC = self.basicRC else {
            assertionFailure("Missing Realm Controller.")
            return false
        }
        // TODO does this warrant having a specialized function to toggle the enabled flag?
        let toggleResult = basicRC.update(kind: nil, interval: nil, isEnabled: !reminder.isEnabled, note: nil, in: reminder)
        switch toggleResult {
        case .success:
            return true
        case .failure(let error):
            UIAlertController.presentAlertVC(for: error, over: self)
            return false
        }
    }

    private func updateIcon(_ icon: ReminderVesselIcon) {
        guard let vessel = self.vesselResult?.value, let basicRC = self.basicRC else {
            assertionFailure("Missing ReminderVessel or Realm Controller")
            return
        }
        let updateResult = basicRC.update(displayName: nil, icon: icon, in: vessel)
        guard case .failure(let error) = updateResult else { return }
        UIAlertController.presentAlertVC(for: error, over: self)
    }
}
