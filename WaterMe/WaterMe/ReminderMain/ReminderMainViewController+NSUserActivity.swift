//
//  ReminderMainViewController+NSUserActivity.swift
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

extension ReminderMainViewController {
    
    func continueUserActivityResultIfNeeded() {
        guard let result = self.userActivityResultToContinue.first else { return }
        self.isReady.insert(.userActivityInProgress)
        self.userActivityResultToContinue.removeFirst()
        switch result {
        case .success(let v):
            let completion: NSUserActivityContinuedHandler = { [weak self] urls in
                self?.isReady.remove(.userActivityInProgress)
                self?.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
                v.completion(urls)
            }
            let failure: UserActivityError?
            switch v.activity {
            case .editReminder(let identifier):
                failure = self.continueActivityEditReminder(with: identifier,
                                                            completion: completion)
            case .editReminderVessel(let identifier):
                failure = self.continueActivityEditReminderVessel(with: identifier,
                                                                  completion: completion)
            case .viewReminder(let identifier):
                failure = self.continueActivityViewReminder(with: identifier,
                                                            completion: completion)
            case .performReminder(let identifier):
                failure = self.continueActivityPerformReminders(with: identifier,
                                                                completion: completion)
            }
            guard let _failure = failure else { return }
            let result = UserActivityToFail(error: _failure, completion: v.completion)
            self.userActivityResultToContinue += [.failure(result)]
            self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
        case .failure(let e):
            let completion: NSUserActivityContinuedHandler = { [weak self] urls in
                self?.isReady.remove(.userActivityInProgress)
                self?.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
                e.completion?(urls)
            }
            self.continueActivityError(e.error, completion: completion)
        }
    }

    private func continueActivityPerformReminders(with identifier: Identifier,
                                                  completion: @escaping NSUserActivityContinuedHandler) -> UserActivityError?
    {
        guard
            let basicRC = self.basicRC,
            let dropVC = self.dropTargetViewController
        else {
            let e = NSError(basicControllerNotFound: true)
            assertionFailure("\(e)")
            e.log()
            return .perform
        }
        let result = basicRC.appendNewPerformToReminders(with: [identifier])
        switch result {
        case .success:
            // do watering animation
            dropVC.isDragInProgress = true
            dropVC.updatePlayAnimationForDrop()
            dropVC.updateDropTargetHeightAndPlayAnimationForDragging(animated: true, completion: nil)
            dropVC.isDragInProgress = false
            // dismiss all other screens so the user can see
            self.dismissAnimatedIfNeeded() { completion(nil) }
            return nil
        case .failure(let error):
            if case .objectDeleted = error {
                return .reminderNotFound
            } else {
                return .perform
            }
        }
    }

    private func continueActivityEditReminder(with identifier: Identifier,
                                              completion: @escaping NSUserActivityContinuedHandler) -> UserActivityError?
    {
        guard let basicRC = self.basicRC else {
            let e = NSError(basicControllerNotFound: true)
            assertionFailure("\(e)")
            e.log()
            return .perform
        }
        let deselect = self.collectionVC?.programmaticalySelectReminder(with: identifier)
        if deselect == nil {
            let e = "Unable to programmatically select reminder: \(identifier.uuid)"
            assertionFailure(e)
            e.log()
        }
        self.dismissAnimatedIfNeeded() {
            self.userChoseEditReminder(with: identifier,
                                       basicRC: basicRC,
                                       userActivityCompletion: completion,
                                       completion: deselect?.1)
        }
        return nil
    }

    private func continueActivityEditReminderVessel(with identifier: Identifier,
                                                    completion: @escaping NSUserActivityContinuedHandler) -> UserActivityError?
    {
        guard let basicRC = self.basicRC else {
            let e = NSError(basicControllerNotFound: true)
            assertionFailure("\(e)")
            e.log()
            return .reminderNotFound
        }
        guard let vessel = basicRC.reminderVessel(matching: identifier).value
            else { return .reminderVesselNotFound }
        self.dismissAnimatedIfNeeded() {
            let vc = ReminderVesselEditViewController.newVC(basicController: basicRC,
                                                            editVessel: vessel,
                                                            userActivityCompletion: completion)
            { vc in
                vc.dismissNoForReal()
            }
            self.present(vc, animated: true, completion: nil)
        }
        return nil
    }

    private func continueActivityViewReminder(with identifier: Identifier,
                                              completion: @escaping NSUserActivityContinuedHandler) -> UserActivityError?
    {
        guard let collectionVC = self.collectionVC else {
            let e = NSError(basicControllerNotFound: true)
            assertionFailure("\(e)")
            e.log()
            return .reminderNotFound
        }
        let deselect = collectionVC.programmaticalySelectReminder(with: identifier)
        if deselect == nil {
            let e = "Unable to programmatically select reminder: \(identifier.uuid)"
            assertionFailure(e)
            e.log()
        }
        var cellView = self.view!
        if let indexPath = deselect?.0,
           let specificView = collectionVC.collectionView?.cellForItem(at: indexPath)
        {
            cellView = specificView
        }
        self.dismissAnimatedIfNeeded() {
            self.userDidSelect(reminderID: identifier,
                               from: cellView,
                               userActivityContinuation: completion,
                               deselectAnimated: deselect?.1,
                               within: collectionVC)
        }
        return nil
    }

    private func continueActivityError(_ error: UserActivityError,
                                       completion: NSUserActivityContinuedHandler?)
    {
        self.dismissAnimatedIfNeeded() {
            UIAlertController.presentAlertVC(for: error, over: self) { _ in
                completion?(nil)
            }
        }
    }
}
