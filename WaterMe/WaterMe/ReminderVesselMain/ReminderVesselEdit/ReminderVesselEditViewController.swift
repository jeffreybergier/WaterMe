//
//  ReminderVesselEditViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/2/17.
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

import Datum
import UIKit
import Calculate

class ReminderVesselEditViewController: StandardViewController, HasBasicController {
    
    typealias CompletionHandler = (UIViewController) -> Void
    
    class func newVC(basicController: BasicController?,
                     editVessel vessel: ReminderVessel? = nil,
                     userActivityCompletion: NSUserActivityContinuedHandler? = nil,
                     completionHandler: @escaping CompletionHandler) -> UIViewController
    {
        let sb = UIStoryboard(name: "ReminderVesselEdit", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let navVC = sb.instantiateInitialViewController() as! UINavigationController
        // swiftlint:disable:next force_cast
        var vc = navVC.viewControllers.first as! ReminderVesselEditViewController
        vc.title = UIApplication.LocalizedString.editVessel
        vc.configure(with: basicController)
        vc.completionHandler = completionHandler
        vc.userActivityCompletion = userActivityCompletion
        if let vessel = vessel {
            vc.vesselResult = .success(vessel)
        } else {
            Analytics.log(event: Analytics.CRUD_Op_RV.create)
            vc.vesselResult = basicController?.newReminderVessel(displayName: nil, icon: nil)
        }
        vc.userActivity = NSUserActivity(kind: .editReminderVessel,
                                         delegate: vc.userActivityDelegate)
        navVC.presentationController?.delegate = vc
        return navVC
    }
    
    /*@IBOutlet*/ private weak var tableViewController: ReminderVesselEditTableViewController?

    private lazy var deleteBBI: UIBarButtonItem = UIBarButtonItem(localizedDeleteButtonWithTarget: self, action: #selector(self.deleteButtonTapped(_:)))
    private lazy var doneBBI: UIBarButtonItem = UIBarButtonItem(localizedDoneButtonWithTarget: self, action: #selector(self.doneButtonTapped(_:)))
    
    var basicRC: BasicController?
    private(set) var vesselResult: Result<ReminderVessel, DatumError>?
    private(set) var completionHandler: CompletionHandler!
    private var userActivityCompletion: NSUserActivityContinuedHandler?
    //swiftlint:disable:next weak_delegate
    private let userActivityDelegate: UserActivityConfiguratorProtocol = UserActivityConfigurator()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = self.deleteBBI
        self.navigationItem.rightBarButtonItem = self.doneBBI

        self.startNotifications()
        self.userActivityDelegate.currentReminderVessel = { [weak self] in
            // should be unowned because this object should not exist longer
            // than the view controller. But since NIL is a possible return value
            // it just seems safer to go with weak
            return ReminderVesselValue(reminderVessel: self?.vesselResult?.value)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Analytics.log(viewOperation: .editReminderVessel)

        self.userActivityCompletion?([self])
        self.userActivityCompletion = nil

        if case .failure(let error) = self.vesselResult! {
            self.vesselResult = nil
            UIAlertController.presentAlertVC(for: error, over: self) { _ in
                self.completionHandler?(self)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destVC = segue.destination as? ReminderVesselEditTableViewController else { return }
        self.tableViewController = destVC
        self.tableViewController?.delegate = self
    }

    private func vesselChanged(_ changes: ReminderVesselChange) {
        switch changes {
        case .change:
            // I gave up trying to get the tableview to reload properly.
            // Now if there is a change in NOT the reminders area
            // the whole tableview reloads.
            // We have to unsubscribe and resubscribe to notifications
            // so that old update commands aren't set after the tableview
            // is reloaded and already up to date.
            self.notificationToken?.invalidate()
            self.tableViewController?.reloadAll()
            DispatchQueue.main.async {
                self.startNotifications()
            }
        case .error(let error):
            Analytics.log(error: error)
            error.log()
            fallthrough
        case .deleted:
            self.reminderVesselWasDeleted()
        }
        // All changes should dirty the User Activity
        self.userDirtiedUserActivity()
    }

    private func reminderVesselWasDeleted() {
        self.tableViewController?.invalidateTokens()
        self.vesselResult = nil
        self.notificationToken?.invalidate()
        self.notificationToken = nil
        self.completionHandler?(self)
    }
    
    @IBAction private func deleteButtonTapped(_ sender: Any) {
        self.view.endEditing(false)
        guard
            let vessel = self.vesselResult?.value,
            let basicRC = self.basicRC,
            let sender = sender as? UIBarButtonItem
        else {
            assertionFailure("Missing ReminderVessel or Realm Controller")
            self.completionHandler?(self)
            return
        }
        let vc = UIAlertController(localizedDeleteConfirmationWithOptions: [],
                                   sender: .right(sender))
        { confirmed in
            guard confirmed == .delete else { return }

            Analytics.log(event: Analytics.CRUD_Op_RV.delete)

            let deleteResult = basicRC.delete(vessel: vessel)
            switch deleteResult {
            case .success:
                self.reminderVesselWasDeleted()
            case .failure(let error):
                UIAlertController.presentAlertVC(for: error,
                                                 over: self,
                                                 from: sender)
                { _ in
                    self.completionHandler?(self)
                }
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction private func doneButtonTapped(_ sender: Any) {
        self.view.endEditing(false)
        guard let vessel = self.vesselResult?.value else { assertionFailure("Missing ReminderVessel"); return; }

        Analytics.log(event: Analytics.CRUD_Op_RV.update)
        
        guard let sender = sender as? UIBarButtonItem else {
            assertionFailure("Expected UIBarButtonItem to call this method")
            return
        }
        if let error = vessel.isModelComplete {
            UIAlertController.presentAlertVC(for: error,
                                             over: self,
                                             from: sender)
            { selection in
                switch selection {
                case .dismiss,
                     .openWaterMeSettings,
                     .reminderMissingMoveLocation,
                     .reminderMissingOtherDescription,
                     .reminderMissingEnabled:
                    assertionFailure()
                    fallthrough
                case .cancel:
                    break
                case .saveAnyway:
                    self.completionHandler?(self)
                case .reminderVesselMissingIcon:
                    self.userChosePhotoChange(controller: self.tableViewController,
                                              sender: .right(sender))
                case .reminderVesselMissingName:
                    self.tableViewController?.nameTextFieldBecomeFirstResponder()
                case .reminderVesselMissingReminder:
                    self.userChoseAddReminder(controller: self.tableViewController)
                }
            }
        } else {
            self.completionHandler?(self)
        }
    }

    func userDirtiedUserActivity() {
        self.userActivity?.needsSave = true
    }
    
    func startNotifications() {
        self.notificationToken =
            self.vesselResult?.value?.observe({ [weak self] in self?.vesselChanged($0) })
    }
    
    var notificationToken: ObservationToken?
    
    deinit {
        self.notificationToken?.invalidate()
    }
}

extension ReminderVesselEditViewController /*: UIAdaptivePresentationControllerDelegate*/ {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.completionHandler(self)
    }
}
