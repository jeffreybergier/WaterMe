//
//  ReminderMainViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 8/21/17.
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

class ReminderMainViewController: StandardViewController, HasProController, HasBasicController {
    
    class func newVC(basic: Result<BasicController, DatumError>,
                     pro: ProController? = nil) -> UINavigationController
    {
        let sb = UIStoryboard(name: "ReminderMain", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let navVC = sb.instantiateInitialViewController() as! UINavigationController
        // swiftlint:disable:next force_cast
        var vc = navVC.viewControllers.first as! ReminderMainViewController
        navVC.navigationBar.style_forceDefaultAppearance()
        vc.title = UIApplication.LocalizedString.appTitle // set here because it works better in UITabBarController
        vc.applicationDidFinishLaunchingError = basic.error
        vc.configure(with: basic.value)
        vc.configure(with: pro)
        vc.resetUserActivity()
        return navVC
    }

    private(set) weak var collectionVC: ReminderCollectionViewController?
    private(set) weak var dropTargetViewController: ReminderFinishDropTargetViewController?
    private var appUpdateAvailableVC: UIViewController?
    private var applicationDidFinishLaunchingError: DatumError?
    var userActivityResultToContinue: [UserActivityResult] = []

    var isReady: ReadyState = []

    private(set) lazy var plantsBBI: UIBarButtonItem = UIBarButtonItem(localizedAddReminderVesselBBIButtonWithTarget: self,
                                                                       action: #selector(self.addPlantButtonTapped(_:)))
    private(set) lazy var settingsBBI: UIBarButtonItem = UIBarButtonItem(localizedSettingsButtonWithTarget: self,
                                                                         action: #selector(self.settingsButtonTapped(_:)))
    private var secretLongPressGestureRecognizer: UILongPressGestureRecognizer?

    var basicRC: BasicController?
    var proRC: ProController?

    let dueDateFormatter = Formatter.newDueDateFormatter
    let haptic = UINotificationFeedbackGenerator()
    //swiftlint:disable:next weak_delegate
    private let userActivityDelegate: UserActivityConfiguratorProtocol = UserActivityConfigurator()

    override func viewDidLoad() {
        super.viewDidLoad()

        // check if there are app store updates available
        self.checkForUpdates()

        // configure toolbar buttons
        self.navigationItem.rightBarButtonItem = self.plantsBBI
        self.navigationItem.leftBarButtonItem = self.settingsBBI
        
        // Configure the bottom bar for iCloud sync
        // Whether the bar shows is related to the user's preference,
        // not the actual capabilities of the device.
        if case .sync = UserDefaults.standard.controllerKind {
            let progressView = CloudSyncProgressView(controller: self.basicRC)
            progressView.lifecycleDelegate = { [weak self] in self?.didUpdate($0, $1) }
            self.toolbarItems = [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(customView: progressView),
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            ]
        }

        // configure my childVC so it can tell me what the user does in the CollectionView
        self.collectionVC?.delegate = self

        // register to find out about purchases that come in at any time
        self.registerForPurchaseNotifications()

        // update layout
        self.updateLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Analytics.log(viewOperation: .reminderList)

        guard self.isReady.contains([.viewDidAppearOnce]) == false else { return }
        self.isReady.insert(.viewDidAppearOnce)
        
        self.secretLongPressGestureRecognizer =
            UIBarButtonItemLongPressGestureRecognizer(barButtonItem: self.plantsBBI,
                                                      target: self,
                                                      action: #selector(self.viewAllPlantsButtonTapped(_:)))
        //
        // We need to make sure that our data is loaded before we call this method
        // If data has not loaded before viewDidAppear is called
        // There is a separate closure that executes and calls
        // `checkForErrorsAndOtherUnexpectedViewControllersToPresent`
        // https://github.com/jeffreybergier/WaterMe2/issues/47
        //
        if self.applicationDidFinishLaunchingError != nil {
            self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
        } else {
            guard self.isReady.completely else { return }
            self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
        }
    }
    
    private func didUpdate(_ progressView: CloudSyncProgressView, _ completion: ((Bool) -> Void)?) {
        switch progressView.lifecycle {
        case .hide:
            self.navigationController?.setToolbarHidden(true, animated: true)
        case .show:
            self.navigationController?.setToolbarHidden(false, animated: true)
        case .present(let error, let sender):
            let errorVC = UIAlertController(error: error, sender: .left((sender, .topCenter))) { _ in
                completion?(true)
            }
            self.present(errorVC, animated: true, completion: nil)
        }
    }

    private func registerForPurchaseNotifications() {
        AppDelegate.shared.purchaseController?.transactionsInFlightUpdated = { [weak self] in
            self?.checkForPurchasesInFlight()
        }
    }

    private func checkForUpdates() {
        UIAlertController.newAppVersionCheckAlert({ controller in
            self.appUpdateAvailableVC = controller
            guard controller != nil, self.isReady.completely else { return }
            self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
        }, { selection in
            switch selection {
            case .cancel:
                self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
            case .update:
                UIApplication.shared.openAppStorePage() { _ in
                    self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
                }
            }
        })
    }

    func checkForErrorsAndOtherUnexpectedViewControllersToPresent() {
        guard self.presentedViewController == nil else {
            // user activities are allowed to continue even if the user is doing something else
            self.continueUserActivityResultIfNeeded()
            return
        }
        
        if let collectionLoadError = self.collectionVC?.reminders?.error {
            self.collectionVC?.reminders = nil
            UIAlertController.presentAlertVC(for: collectionLoadError, over: self) { _ in
                self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
            }
        } else if let vc = UIAlertController.newLocalizedDarkModeImproperlyConfigured() {
            self.present(vc, animated: true, completion: nil)
        } else if UserDefaults.standard.hasCloudSyncInfoShown == false {
            let vc = CloudSyncInfoViewController.newVC() { vc in
                UserDefaults.standard.hasCloudSyncInfoShown = true
                vc.dismissNoForReal() {
                    self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
                }
            }
            self.present(vc, animated: true, completion: nil)
        } else if let error = self.applicationDidFinishLaunchingError {
            self.applicationDidFinishLaunchingError = nil
            UIAlertController.presentAlertVC(for: error, over: self) { _ in
                self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
            }
        } else if let migrator = AppDelegate.shared.coreDataMigrator, let basicRC = self.basicRC {
            let vc = CoreDataMigratorViewController.newVC(migrator: migrator, basicRC: basicRC) { vc, _ in
                AppDelegate.shared.coreDataMigrator = nil
                vc.dismissNoForReal() {
                    self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
                }
            }
            self.present(vc, animated: true, completion: nil)
        } else if let updateAlert = self.appUpdateAvailableVC {
            self.appUpdateAvailableVC = nil
            Analytics.log(viewOperation: .alertUpdateAvailable)
            self.present(updateAlert, animated: true, completion: nil)
        } else if self.userActivityResultToContinue.isEmpty == false {
            self.continueUserActivityResultIfNeeded()
        } else {
            self.checkForPurchasesInFlight()
        }
    }

    private func checkForPurchasesInFlight() {
        guard self.presentedViewController == nil else { return }

        let pc = AppDelegate.shared.purchaseController
        guard let transaction = pc?.nextTransactionForPresentingToUser() else { return }
        let _vc = PurchaseThanksViewController.newVC(for: transaction) { vc in
            guard let vc = vc else { self.checkForPurchasesInFlight(); return; }
            vc.dismissNoForReal() {
                self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
            }
        }
        guard let vc = _vc else { return }
        self.present(vc, animated: true, completion: nil)
    }

    func resetUserActivity() {
        self.userActivity = nil
        self.userActivity?.needsSave = true
        self.userActivity?.becomeCurrent()
    }

    @IBAction private func addPlantButtonTapped(_ sender: Any) {
        guard let basicRC = self.basicRC else { return }
        let editVC = ReminderVesselEditViewController.newVC(basicController: basicRC,
                                                            editVessel: nil)
        { vc in
            vc.dismissNoForReal() {
                self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
            }
        }
        self.present(editVC, animated: true, completion: nil)
    }

    @IBAction private func viewAllPlantsButtonTapped(_ sender: Any) {
        guard
            let sender = sender as? UILongPressGestureRecognizer,
            case .began = sender.state
        else { return }
        let vc = ReminderVesselMainViewController.newVC(basicController: self.basicRC)
        { vc in
            vc.dismissNoForReal()
        }
        self.present(vc, animated: true, completion: nil)
    }

    @IBAction private func settingsButtonTapped(_ sender: Any) {
        let vc = SettingsMainViewController.newVC() { vc in
            vc.dismissNoForReal() {
                // re-register to receive purchase updates
                self.registerForPurchaseNotifications()
                self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
            }
        }
        self.present(vc, animated: true, completion: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // if dropTargetViewController it causes the collectionview insets to be updated
        if self.dropTargetViewController == nil {
            self.updateCollectionViewInsets()
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        // if dropTargetViewController it causes the collectionview insets to be updated
        if self.dropTargetViewController == nil {
            self.updateCollectionViewInsets()
        }
    }

    // Delegate from CollectionViewController
    func forceUpdateCollectionViewInsets() {
        self.updateCollectionViewInsets()
    }

    private func updateCollectionViewInsets() {
        let verticalSizeClassIsRegular = self.traitCollection.verticalSizeClassIsRegular
        let layoutDirectionIsLeftToRight = self.traitCollection.layoutDirection.isLeftToRight
        let customInset: UIEdgeInsets
        switch verticalSizeClassIsRegular {
        case true:
            // get the width and set the custom inset
            let dragViewHeight = self.dropTargetViewController?.dropTargetViewHeight ?? 0
            customInset = UIEdgeInsets(top: dragViewHeight, left: 0, bottom: 0, right: 0)
            // we need custom scroll insets in portrait
            self.collectionVC?.collectionView?.scrollIndicatorInsets = customInset
        case false:
            // Scroll Indicators can have normal behavior in landscape
            self.collectionVC?.collectionView?.scrollIndicatorInsets = .zero
            // get the width and set the custom inset
            let dragViewWidth = self.dropTargetViewController?.view.bounds.width ?? 0
            customInset = layoutDirectionIsLeftToRight
                ? UIEdgeInsets(top: 0, left: dragViewWidth, bottom: 0, right: 0)
                : UIEdgeInsets(top: 0, left: 0, bottom: 0, right: dragViewWidth)
        }

        // BUGFIX: http://crashes.to/s/254b2d6597f
        // Sometimes the collectionview does not like having its inset changed
        // without first invalidating the layout
        // 🤞 fix as I've never seen this bug in person
        // just listening to the message from Apple
        self.collectionVC?.flow?.invalidateLayout()
        self.collectionVC?.collectionView?.contentInset = customInset
    }

    private func updateLayout() {
        self.settingsBBI.style_updateSettingsButtonInsets(for: self.traitCollection)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateLayout()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var hasBasic = segue.destination as? HasBasicController
        hasBasic?.configure(with: self.basicRC)
        var hasPro = segue.destination as? HasProController
        hasPro?.configure(with: self.proRC)

        if let destVC = segue.destination as? ReminderCollectionViewController {
            self.collectionVC = destVC
            destVC.allDataReady = { [weak self] _ in
                //
                // When all data is ready, we need to make sure the view has appeared
                // If it has already appeared once, then we need to check to see
                // If there is anything to show.
                // It turns out that viewDidAppear often happens before
                // All of the data loads
                // I'm surprised this didn't cause an issue up to this point
                // https://github.com/jeffreybergier/WaterMe2/issues/47
                //
                self?.isReady.insert(.allDataLoaded)
                guard self?.isReady.completely == true else { return }
                self?.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
            }
        } else if let destVC = segue.destination as? ReminderFinishDropTargetViewController {
            destVC.delegate = self
            self.dropTargetViewController = destVC
        }
    }
}

extension ReminderMainViewController: ReminderFinishDropTargetViewControllerDelegate {

    func userDidCancelDrag(within: ReminderFinishDropTargetViewController) {
        // We donated a new activity when the drag started
        // Now we need to restore the current activity back to default
        self.resetUserActivity()
    }

    func userDidStartDrag(with values: [ReminderAndVesselValue],
                          within: ReminderFinishDropTargetViewController)
    {
        self.userActivityDelegate.currentReminderAndVessel = {
            return values.first
        }
        // Donate this activity so Siri might recommend it later
        let activity = NSUserActivity(kind: .performReminder,
                                      delegate: self.userActivityDelegate)
        self.userActivity = activity
        activity.needsSave = true
        activity.becomeCurrent()
    }

    func animateAlongSideDropTargetViewResize(within: ReminderFinishDropTargetViewController) -> (() -> Void)? {
        return { self.updateCollectionViewInsets() }
    }
}

extension Reminder {
    var localizedAlertTitle: String {
        if let displayName = self.vessel?.shortLabelSafeDisplayName {
            let format = ReminderMainViewController.LocalizedString.reminderAlertTitle
            return String.localizedStringWithFormat(format, self.kind.localizedLongString, displayName)
        } else {
            return self.kind.localizedLongString
        }
    }
    func localizedAlertMessage(withLocalizedDateString dateString: String) -> String {
        if let note = self.note {
            let format = ReminderMainViewController.LocalizedString.reminderAlertMessage2Arg
            return String.localizedStringWithFormat(format, dateString, note)
        } else {
            let format = ReminderMainViewController.LocalizedString.reminderAlertMessage1Arg
            return String.localizedStringWithFormat(format, dateString)
        }
    }
}

extension ReminderMainViewController {
    struct ReadyState: OptionSet {
        let rawValue: Int
        static let viewDidAppearOnce = ReadyState(rawValue: 1)
        static let allDataLoaded = ReadyState(rawValue: 2)
        static let userActivityInProgress = ReadyState(rawValue: 4)

        var completely: Bool {
            return self.contains([.viewDidAppearOnce, .allDataLoaded])
                && !self.contains([.userActivityInProgress])
        }
    }
}
