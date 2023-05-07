//
//  ReminderEditViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/22/17.
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

import DatumL
import IntentsUI
import UIKit
import Calculate

class ReminderEditViewController: StandardViewController, HasBasicController {

    enum Purpose {
        case new(ReminderVessel), existing(Reminder)
    }
    typealias CompletionHandler = (UIViewController) -> Void

    class func newVC(basicController: BasicController?,
                     purpose: Purpose,
                     userActivityCompletion: NSUserActivityContinuedHandler? = nil,
                     completionHandler: @escaping CompletionHandler) -> UIViewController
    {
        let sb = UIStoryboard(name: "ReminderEdit", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let navVC = sb.instantiateInitialViewController() as! UINavigationController
        // swiftlint:disable:next force_cast
        var vc = navVC.viewControllers.first as! ReminderEditViewController
        vc.title = UIApplication.LocalizedString.editReminder
        vc.configure(with: basicController)
        vc.completionHandler = completionHandler
        vc.userActivityCompletion = userActivityCompletion
        switch purpose {
        case .new(let vessel):
            Analytics.log(event: Analytics.CRUD_Op_R.create)
            vc.reminderResult = basicController?.newReminder(for: vessel)
        case .existing(let reminder):
            vc.reminderResult = .success(reminder)
        }
        vc.userActivity = NSUserActivity(kind: .editReminder,
                                         delegate: vc.userActivityDelegate)
        navVC.presentationController?.delegate = vc
        return navVC
    }

    /*@IBOutlet*/ private weak var tableViewController: ReminderEditTableViewController?

    private lazy var deleteBBI: UIBarButtonItem = UIBarButtonItem(localizedDeleteButtonWithTarget: self,
                                                                  action: #selector(self.deleteButtonTapped(_:)))
    private lazy var doneBBI: UIBarButtonItem = UIBarButtonItem(localizedDoneButtonWithTarget: self,
                                                                action: #selector(self.doneButtonTapped(_:)))

    var basicRC: BasicController?
    private(set) var reminderResult: Result<Reminder, DatumError>?
    private var completionHandler: CompletionHandler?
    private var userActivityCompletion: NSUserActivityContinuedHandler?
    // swiftlint:disable:next weak_delegate
    private let userActivityDelegate: UserActivityConfiguratorProtocol = UserActivityConfigurator()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = self.deleteBBI
        self.navigationItem.rightBarButtonItem = self.doneBBI

        self.tableViewController?.delegate = self
        self.startNotifications()
        self.userActivityDelegate.currentReminderAndVessel = { [weak self] in
            // should be unowned because this object should not exist longer
            // than the view controller. But since NIL is a possible return value
            // it just seems safer to go with weak
            return ReminderAndVesselValue(reminder: self?.reminderResult?.value)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.log(viewOperation: .editReminder)
        self.userActivityCompletion?([self])
        self.userActivityCompletion = nil
        if case .failure(let error) = self.reminderResult! {
            self.stopNotifications()
            self.reminderResult = nil
            UIAlertController.presentAlertVC(for: error, over: self) { _ in
                self.completionHandler?(self)
            }
        }
    }

    private func reminderChanged(_ change: ReminderChange) {
        switch change {
        case .change:
            self.tableViewController?.tableView.reloadData()
        case .error(let error):
            Analytics.log(error: error)
            error.log()
            fallthrough
        case .deleted:
            self.stopNotifications()
            self.reminderResult = nil
            self.completionHandler?(self)
        }
        // dirty the user activity because the item changed
        self.userDirtiedUserActivity()
    }

    private func update(kind: ReminderKind? = nil,
                        interval: Int? = nil,
                        isEnabled: Bool? = nil,
                        note: String? = nil,
                        fromKeyboard: Bool = false)
    {
        // make sure we have the info we needed
        guard
            let reminder = self.reminderResult?.value,
            let basicRC = self.basicRC
        else {
            assertionFailure("Missing Reminder or Realm Controller")
            return
        }
        // if this came from the keyboard stop notifications
        // so the keyboard doesn't get dismissed because of tableview reloads
        if fromKeyboard == true {
            self.stopNotifications()
        }
        // after we exit this scope, we need to turn notifications back on
        // again, only if the from keyboard variable is true
        defer {
            if fromKeyboard == true {
                self.startNotifications()
                // item was changed outside of notification block
                self.userDirtiedUserActivity()
            }
        }
        // update the Reminder in Realm
        let updateResult = basicRC.update(kind: kind,
                                          interval: interval,
                                          isEnabled: isEnabled,
                                          note: note,
                                          in: reminder)

        // show the user errors that may have ocurred
        guard case .failure(let error) = updateResult else { return }
        UIAlertController.presentAlertVC(for: error, over: self) { _ in
            self.tableViewController?.tableView.reloadData()
        }
    }

    private func intervalChosen(popoverSourceView: UIView?,
                                deselectHandler: @escaping () -> Void)
    {
        self.view.endEditing(false)
        guard let existingValue = self.reminderResult?.value?.interval else {
            assertionFailure("No Reminder Present")
            self.completionHandler?(self)
            return
        }
        let vc = ReminderIntervalPickerViewController.newVC(from: self.storyboard,
                                                            existingValue: existingValue,
                                                            popoverSourceView: popoverSourceView)
        { vc, newValue in
            vc.dismissNoForReal {
                deselectHandler()
                guard let newValue = newValue else { return }
                self.update(interval: newValue)
            }
        }
        self.present(vc, animated: true, completion: nil)
    }

    @IBAction private func deleteButtonTapped(_ sender: Any) {
        self.view.endEditing(false)
        guard
            let reminder = self.reminderResult?.value,
            let basicRC = self.basicRC,
            let sender = sender as? UIBarButtonItem
        else {
            assertionFailure("Missing Reminder or Realm Controller.")
            self.completionHandler?(self)
            return
        }

        let options: UIAlertController.ReminderDeleteConfirmationOptions
            = reminder.isEnabled
            ? [.pause]
            : []
        let confirmation = UIAlertController(localizedDeleteConfirmationWithOptions: options,
                                             sender: .right(sender))
        { confirmed in
            switch confirmed {
            case.delete:
                Analytics.log(event: Analytics.CRUD_Op_R.delete)
                let deleteResult = basicRC.delete(reminder: reminder)
                switch deleteResult {
                case .success:
                    self.completionHandler?(self)
                case .failure(let error):
                    UIAlertController.presentAlertVC(for: error, over: self, from: sender)
                }
            case .pause:
                Analytics.log(event: Analytics.CRUD_Op_R.pause)
                let pauseResult = basicRC.update(kind: nil, interval: nil, isEnabled: !reminder.isEnabled, note: nil, in: reminder)
                switch pauseResult {
                case .success:
                    self.completionHandler?(self)
                case .failure(let error):
                    UIAlertController.presentAlertVC(for: error, over: self, from: sender)
                }
            default:
                return
            }
        }
        self.present(confirmation, animated: true, completion: nil)
    }

    @IBAction private func doneButtonTapped(_ _sender: Any) {
        Analytics.log(event: Analytics.CRUD_Op_R.update)
        self.view.endEditing(false)
        guard let sender = _sender as? UIBarButtonItem else {
            let message = "Expected UIBarButtonItem to call this method"
            message.log()
            assertionFailure(message)
            self.completionHandler?(self)
            return
        }
        guard let reminder = self.reminderResult?.value else {
            self.completionHandler?(self)
            return
        }
        if let error = reminder.isModelComplete {
            UIAlertController.presentAlertVC(for: error,
                                             over: self,
                                             from: sender)
            { selection in
                switch selection {
                case .dismiss,
                     .openWaterMeSettings,
                     .reminderVesselMissingIcon,
                     .reminderVesselMissingName,
                     .reminderVesselMissingReminder:
                    assertionFailure()
                    fallthrough
                case .cancel:
                    break
                case .saveAnyway:
                    self.completionHandler?(self)
                case .reminderMissingEnabled:
                    self.tableViewController?.forceScrollToIsEnabledRow()
                case .reminderMissingMoveLocation, .reminderMissingOtherDescription:
                    self.tableViewController?.forceTextFieldToBecomeFirstResponder()
                }
            }
        } else {
            self.completionHandler?(self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tableVC = segue.destination as? ReminderEditTableViewController {
            self.tableViewController = tableVC
        }
    }

    private func userDirtiedUserActivity() {
        self.userActivity?.needsSave = true
    }

    private func startNotifications() {
        let token1 = self.reminderResult?.value?.observe { [weak self] in self?.reminderChanged($0) }
        self.tokens = [token1].compactMap { $0 }
    }

    private func stopNotifications() {
        self.tokens.invalidateTokens()
        self.tokens = []
    }

    private var tokens: [ObservationToken] = []

    deinit {
        self.stopNotifications()
    }
}

extension ReminderEditViewController: ReminderEditTableViewControllerDelegate {

    func userChangedKind(to newKind: ReminderKind,
                         byUsingKeyboard usingKeyboard: Bool,
                         within: ReminderEditTableViewController)
    {
        self.update(kind: newKind, fromKeyboard: usingKeyboard)
    }

    func userChangedNote(toNewNote newNote: String,
                         within: ReminderEditTableViewController)
    {
        self.update(note: newNote, fromKeyboard: true)
    }

    func userChangedIsEnabled(to newIsEnabled: Bool,
                              within: ReminderEditTableViewController)
    {
        self.update(isEnabled: newIsEnabled)
    }

    func userDidSelectChangeInterval(popoverSourceView: UIView?,
                                     deselectHandler: @escaping () -> Void,
                                     within: ReminderEditTableViewController)
    {
        self.intervalChosen(popoverSourceView: popoverSourceView,
                            deselectHandler: deselectHandler)
    }

    func userDidSelect(siriShortcut: ReminderEditTableViewController.SiriShortcut,
                       deselectRowAnimated: ((Bool) -> Void)?,
                       within: ReminderEditTableViewController)
    {
        guard #available(iOS 12.0, *) else {
            let vc = UIAlertController(localizedSiriShortcutsUnavailableAlertWithCompletionHandler: {
                deselectRowAnimated?(true)
            })
            self.present(vc, animated: true, completion: nil)
            return
        }
        let activity: NSUserActivity
        switch siriShortcut {
        case .editReminder:
            guard
                let _activity = self.userActivity,
                _activity.activityType == RawUserActivity.editReminder.rawValue
            else {
                assertionFailure("Unexpected User Activity")
                return
            }
            activity = _activity
        case .viewReminder:
            activity = NSUserActivity(kind: .viewReminder,
                                      delegate: self.userActivityDelegate)
        case .performReminder:
            activity = NSUserActivity(kind: .performReminder,
                                      delegate: self.userActivityDelegate)
        }
        activity.needsSave = true
        activity.becomeCurrent()
        let shortcut = INShortcut(userActivity: activity)
        let vc = ClosureDelegatingAddVoiceShortcutViewController(shortcut: shortcut)
        vc.completionHandler = { [unowned self] vc, result in
            self.userActivity?.becomeCurrent()
            vc.dismissNoForReal {
                deselectRowAnimated?(true)
                guard case .failure(let error) = result else { return }
                UIAlertController.presentAlertVC(for: error, over: self)
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
}

extension ReminderEditViewController /*: UIAdaptivePresentationControllerDelegate*/ {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.completionHandler?(self)
    }
}
