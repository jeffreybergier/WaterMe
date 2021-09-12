//
//  ReminderMainViewController+ReminderCollectionViewControllerDelegate.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 8/2/18.
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

extension ReminderMainViewController: ReminderCollectionViewControllerDelegate {

    func dragSessionWillBegin(_ session: UIDragSession,
                              within viewController: ReminderCollectionViewController)
    {
        self.haptic.prepare()
        self.settingsBBI.isEnabled = false
        self.plantsBBI.isEnabled = false
    }

    func dragSessionDidEnd(_ session: UIDragSession,
                           within viewController: ReminderCollectionViewController)
    {
        self.settingsBBI.isEnabled = true
        self.plantsBBI.isEnabled = true
    }

    func userDidPerformDrop(with reminders: [Identifier],
                            onTargetZoneWithin controller: ReminderFinishDropTargetViewController?)
    {
        // We donated a new activity when the drag started
        // Now we need to restore the current activity back to default
        self.resetUserActivity()

        // Then we need to work on marking these reminders as done.
        guard let results = self.basicRC?.appendNewPerformToReminders(with: reminders) else { return }
        switch results {
        case .failure(let error):
            self.haptic.notificationOccurred(.error)
            UIAlertController.presentAlertVC(for: error, over: self)
        case .success:
            self.haptic.notificationOccurred(.success)
            Analytics.log(event: Analytics.CRUD_Op_R.performDrag,
                          extras: Analytics.CRUD_Op_R.extras(count: reminders.count))
            let _notPermVC = UIAlertController(newPermissionAlertIfNeededPresentedFrom: nil,
                                               selectionCompletionHandler: nil)
            guard let notPermVC = _notPermVC else { return }
            self.present(notPermVC, animated: true, completion: nil)
        }
    }

    func userDidSelect(reminderID: Identifier,
                       from view: UIView,
                       userActivityContinuation: NSUserActivityContinuedHandler?,
                       deselectAnimated: ((Bool) -> Void)?,
                       within viewController: ReminderCollectionViewController)
    {
        guard let basicRC = self.basicRC else {
            assertionFailure("Missing Realm Controller")
            return
        }
        Analytics.log(viewOperation: .reminderSummary)

        // closure that needs to be executed whenever all the alerts have disappeared
        let viewDidAppearActions = { (animated: Bool) in
            deselectAnimated?(animated)
            self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
        }

        // create the summary view controller
        let alert = ReminderSummaryViewController.newVC(reminderID: reminderID,
                                                        basicController: basicRC,
                                                        hapticGenerator: self.haptic,
                                                        sourceView: view,
                                                        userActivityContinuation: userActivityContinuation)
        { action, identifier, vc in
            vc.dismissNoForReal() {
                switch action {
                case .cancel:
                    viewDidAppearActions(true)
                case .editReminder:
                    self.userChoseEditReminder(with: identifier,
                                               basicRC: basicRC,
                                               completion: viewDidAppearActions)
                case .editReminderVessel:
                    self.userChoseEditVessel(withReminderIdentifier: identifier,
                                             basicRC: basicRC,
                                             completion: viewDidAppearActions)
                case .performReminder:
                    self.userChosePerformReminders(with: [identifier],
                                                   in: nil,
                                                   from: view,
                                                   basicRC: basicRC,
                                                   completion: viewDidAppearActions)
                }
            }
        }
        // present the new VC
        self.present(alert, animated: true, completion: nil)
    }

    func userChoseEditReminder(with identifier: Identifier,
                               basicRC: BasicController,
                               userActivityCompletion: NSUserActivityContinuedHandler? = nil,
                               completion: ((Bool) -> Void)?)
    {
        let result = basicRC.reminder(matching: identifier)
        switch result {
        case .success(let reminder):
            let vc = ReminderEditViewController.newVC(basicController: self.basicRC,
                                                      purpose: .existing(reminder),
                                                      userActivityCompletion: userActivityCompletion)
            { vc in
                vc.dismissNoForReal(completion: { completion?(true) })
            }
            self.present(vc, animated: true, completion: nil)
        case .failure(let error):
            self.present(error: error, with: { completion?(true) })
        }
    }

    func userChoseEditVessel(withReminderIdentifier identifier: Identifier,
                             basicRC: BasicController,
                             completion: ((Bool) -> Void)?)
    {
        let result = basicRC.reminder(matching: identifier)
        switch result {
        case .success(let reminder):
            let vc = ReminderVesselEditViewController.newVC(basicController: self.basicRC,
                                                            editVessel: reminder.vessel)
            { vc in
                vc.dismissNoForReal(completion: { completion?(true) })
            }
            self.present(vc, animated: true, completion: nil)
        case .failure(let error):
            self.present(error: error, with: { completion?(true) })
        }
    }

    private func userChosePerformReminders(with identifiers: [Identifier],
                                           in _: UIAlertAction?,
                                           from view: UIView,
                                           basicRC: BasicController,
                                           completion: ((Bool) -> Void)?)
    {
        // update the database
        let result = basicRC.appendNewPerformToReminders(with: identifiers)
        switch result {
        case .success:
            // they performed the reminder, now analytics it
            Analytics.log(event: Analytics.CRUD_Op_R.performLegacy)
            // perform the haptic for success
            self.haptic.notificationOccurred(.success)
            // next we need to see if they are allowing / want to give us permission to send push notifications
            let _notificationPermissionVC = UIAlertController(newPermissionAlertIfNeededPresentedFrom: .left((view, .center)))
            { _ in
                completion?(true)
            }
            // if we got a VC to present, then we need to show it
            // otherwise, just call the completion handler
            guard let notificationPermissionVC = _notificationPermissionVC else {
                completion?(true)
                return
            }
            self.present(notificationPermissionVC, animated: true, completion: nil)
        case .failure(let error):
            // perform the haptic for error
            self.haptic.notificationOccurred(.error)
            // present the alert for the error
            self.present(error: error, with: { completion?(true) })
        }
    }

    private func present(error: DatumError, with completion: (() -> Void)?) {
        UIAlertController.presentAlertVC(for: error, over: self)
    }
}
