//
//  AppDelegate.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/7/17.
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

import Store
import DatumL
import UserNotifications
import AVFoundation
import StoreKit
import UIKit
import Calculate
import CloudKit
import Combine
import ServerlessLogger

@UIApplicationMain
// swiftlint:disable:next type_body_length
class AppDelegate: UIResponder, UIApplicationDelegate {

    // swiftlint:disable:next force_cast
    class var shared: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }

    // swiftlint:disable weak_delegate
    private let notificationUIDelegate = ReminderNotificationUIDelegate()
    private let loggerDelegate = LoggerErrorDelegate()
    private(set) var reminderObserver: GlobalReminderObserver?
    private lazy var basicControllerResult = NewBasicController(of: UserDefaults.standard.controllerKind)

    let purchaseController = PurchaseController()
    var coreDataMigrator: Migratable? = DatumMigrator
    var window: UIWindow?
    var userDefaultObserverTokens: [NSKeyValueObservation] = []

    private var rootVC: ReminderMainViewController? {
        let navVC = self.window?.rootViewController as? UINavigationController
        let vc = navVC?.viewControllers.first as? ReminderMainViewController
        assert(vc != nil)
        return vc
    }

    // swiftlint:disable:next function_body_length
    override init() {
        super.init()

        // configure logging
        UIDevice.current.isBatteryMonitoringEnabled = true // turned on for logger
        LoggableConfigure(with: self.loggerDelegate)

        // configure simulator
        self.simulator_configure()

        // configure main thread checking
        DispatchQueue.configureMainQueue()

        // as early as possible, configure standard defaults
        let ud = UserDefaults.standard
        ud.configure()

        // make re-usable closures for notifications I'll register for later
        let appearanceChanges = { [weak self] in
            DispatchQueue.main.async {
                // if the window is not configured yet, bail
                guard
                    let self = self,
                    let window = self.window
                else { return }

                // need to rip the view hierarchy out of the window and put it back in
                // in order for the new UIAppearance to take effect
                UIApplication.style_configure()

                // force window to update everything by
                // get the old vc in iOS 13
                var newVC: UIViewController!
                if #available(iOS 13.0, *) {
                    newVC = window.rootViewController
                }
                // create a new VC in older versions
                // for some reason this is needed
                if newVC == nil {
                    let result = self.basicControllerResult
                    newVC = ReminderMainViewController.newVC(basic: result)
                }
                // clear the vc from the window
                window.rootViewController = nil
                // configuring the window
                window.style_configure()
                // replace with newVC
                window.rootViewController = newVC
            }
        }
        let notificationChanges = { [weak self] in
            DispatchQueue.main.async {
                self?.reminderObserver?.notificationPermissionsMayHaveChanged()
            }
        }
        let cloudSyncChanges = { [weak self] in
            DispatchQueue.main.async {
                autoreleasepool {
                    // Clean things up
                    self?.window?.rootViewController = nil
                    self?.window?.style_configureTemporaryReset()
                    self?.basicControllerResult = .failure(.load)
                    self?.reminderObserver = nil
                }
                // Need to wait for CoreData to be fully deallocated
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    // Create new VC with recreated data source
                    let controller = NewBasicController(of: UserDefaults.standard.controllerKind)
                    self?.reminderObserver = .init(result: controller)
                    self?.basicControllerResult = controller
                    self?.window?.style_unconfigureTemporaryReset()
                    self?.window?.rootViewController = ReminderMainViewController.newVC(basic: controller)
                }
            }
        }
        // register for notifications about the increase contrast setting
        let nc = NotificationCenter.default
        _ = nc.addObserver(forName: UIAccessibility.darkerSystemColorsStatusDidChangeNotification,
                           object: nil,
                           queue: nil)
        { _ in
            appearanceChanges()
        }
        // register for notifications if user defaults change while the app is running
        let token1 = ud.observe(\.INCREASE_CONTRAST) { _, _ in
            appearanceChanges()
        }
        let token2 = ud.observe(\.DARK_MODE) { _, _ in
            appearanceChanges()
        }
        let token3 = ud.observe(\.REMINDER_HOUR) { _, _ in
            notificationChanges()
        }
        let token4 = ud.observe(\.NUMBER_OF_REMINDER_DAYS) { _, _ in
            notificationChanges()
        }
        let token5 = ud.observe(\.FIRST_RUN) { _, _ in
            notificationChanges()
        }
        let token6 = ud.observe(\.CLOUD_SYNC) { _, _ in
            cloudSyncChanges()
        }

        self.userDefaultObserverTokens += [token1, token2, token3, token4, token5, token6]
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        // configure background fetch
        if #available(iOS 14, *) {
            application.setMinimumBackgroundFetchInterval(3/*hours*/ * 60/*minutes*/ * 60/*seconds*/)
        } else {
            application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalNever)
        }

        // Remote notifications used for CloudKit
        application.registerForRemoteNotifications()

        // see if there is a new build
        _ = {
            // check the build and see if its new
            let ud = UserDefaults.standard
            let oldBuild = ud.lastBuildNumber
            let currentBuild = Bundle.main.buildNumber
            if oldBuild != currentBuild {
                ud.lastBuildNumber = currentBuild
                ud.requestReviewDate = Date()
            }
        }()

        // configure my notification delegate
        UNUserNotificationCenter.current().delegate = self.notificationUIDelegate

        // style the app with UIAppearance methods
        UIApplication.style_configure()

        // Configure audio so the water video does not pause the users music
        try? AVAudioSession.sharedInstance().setCategory(.ambient)

        let result = self.basicControllerResult
        self.reminderObserver = GlobalReminderObserver(result: result)
        let vc = ReminderMainViewController.newVC(basic: result)

        // When a new build is detected, we set a date
        // Two weeks after that date, the user is eligible to be asked for a review
        // Next time they water plants, they will be asked (assuming the system cooperates)
        result.value?.userDidPerformReminder = { _ in
            let now = Date()
            let ud = UserDefaults.standard
            guard
                let reviewDate = ud.requestReviewDate,
                let forwardDate = Calendar.current.date(byAdding: .weekOfMonth,
                                                        value: 2,
                                                        to: reviewDate),
                now >= forwardDate
            else { return }
            "Requested App Review with SKStoreReviewController".log(as: .info)
            Analytics.log(event: Analytics.Event.reviewRequested)
            SKStoreReviewController.requestReview()
            ud.requestReviewDate = nil // nil this out so they won't be asked again until next update
        }

        // configure window
        let window = self.window ?? UIWindow(frame: UIScreen.main.bounds)
        window.style_configure()
        window.rootViewController = vc

        // show window
        self.window = window
        window.makeKeyAndVisible()

        return true
    }

    func application(_ application: UIApplication,
                     willContinueUserActivityWithType userActivityType: String) -> Bool
    {
        guard RawUserActivity(rawValue: userActivityType) != nil else {
            return false
        }
        return true
    }

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping NSUserActivityContinuedHandler) -> Bool
    {
        let result: UserActivityResult
            = userActivity.restoredUserActivityResult
                .bimap(success: { UserActivityToContinue(activity: $0, completion: restorationHandler) },
                       failure: { UserActivityToFail(error: $0, completion: restorationHandler) })
        self.rootVC?.userActivityResultToContinue += [result]
        let isReady = self.rootVC?.isReady ?? []
        guard isReady.completely else { return true }
        self.rootVC?.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
        return true
    }

    func application(_ application: UIApplication,
                     didFailToContinueUserActivityWithType userActivityType: String,
                     error: Error)
    {
        let error = error as NSError
        guard error.code != NSUserCancelledError else {
            return
        }
        let result: UserActivityResult
            = .failure(UserActivityToFail(error: .perform, completion: nil))
        self.rootVC?.userActivityResultToContinue += [result]
        let isReady = self.rootVC?.isReady ?? []
        guard isReady.completely else { return }
        self.rootVC?.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
    }

    func application(_ application: UIApplication, shouldSaveSecureApplicationState coder: NSCoder) -> Bool {
        return true
    }

    func application(_ application: UIApplication,
                     shouldRestoreSecureApplicationState coder: NSCoder) -> Bool
    {
        let _savedBuild = coder.decodeObject(forKey: UIApplication.stateRestorationBundleVersionKey) as? String
        let _currentBuild = Bundle(for: type(of: self)).infoDictionary?[kCFBundleVersionKey as String] as? String
        guard
            let savedBuild = _savedBuild,
            let currentBuild = _currentBuild,
            currentBuild == savedBuild
        else { return false }
        return true
    }

    @available(*, deprecated, message: "This is deprecated. Only implemented for old iOS support.")
    func application(_ application: UIApplication,
                     shouldSaveApplicationState coder: NSCoder) -> Bool
    {
        return self.application(application, shouldSaveSecureApplicationState: coder)
    }

    @available(*, deprecated, message: "This is deprecated. Only implemented for old iOS support.")
    func application(_ application: UIApplication,
                     shouldRestoreApplicationState coder: NSCoder) -> Bool
    {
        return self.application(application, shouldRestoreSecureApplicationState: coder)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        "didRegisterForRemoteNotifications".log(as: .debug)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        error.log()
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        self.common_application(application, performFetchWithCompletionHandler: completionHandler)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        self.common_application(application, performFetchWithCompletionHandler: completionHandler)
    }

    private var backgroundUpdateSink: Any?

    func common_application(_ application: UIApplication, performFetchWithCompletionHandler iOS_completion: @escaping (UIBackgroundFetchResult) -> Void) {
        guard #available(iOS 14.0, *), let progress = self.basicControllerResult.value?.syncProgress else {
            iOS_completion(.noData)
            return
        }

        // This code is long and horrible, but it basically just sits around
        // and waits for iCloud to sync. It has a couple of failsafes in case
        // things appear not to be syncing correctly.

        // setup objects to be finished later
        let startTime = Date()
        var syncTimer: Timer? // the normal timer that is waiting for the sync to finish
        var startWaitLimitTimer: Timer? // timer that shuts everything down if Sink never produces any signals
        var finishWaitLimitTimer: Timer? // timer that waits super long and shuts things down if sync doesn't finish
        let task = application.beginBackgroundTask(withName: "performFetchWithCompletionHandler:", expirationHandler: nil)

        // configure timings
        let syncTime: TimeInterval = 4
        let startWaitLimitTime: TimeInterval = 5
        let finishWaitLimitTime: TimeInterval = 23
        let scheduleWaitLimitTime: TimeInterval = 2

        let completion: (Timer) -> Void = { timer in
            String(format: "Background Sync Completed: syncTimer: %.02fs", Date().timeIntervalSince(startTime)).log(as: .debug)
            timer.invalidate()
            application.endBackgroundTask(task)
            iOS_completion(.newData)
        }

        let preCompletion: (Timer) -> Void = { [weak self] timer in
            (self?.backgroundUpdateSink as? AnyCancellable)?.cancel()
            self?.backgroundUpdateSink = nil
            timer.invalidate()
            syncTimer?.invalidate()
            startWaitLimitTimer?.invalidate()
            finishWaitLimitTimer?.invalidate()
            self?.reminderObserver?.dataChanged(of: .all)
            Timer.scheduledTimer(withTimeInterval: scheduleWaitLimitTime,
                                 repeats: false,
                                 block: completion)
        }

        startWaitLimitTimer = Timer.scheduledTimer(withTimeInterval: startWaitLimitTime, repeats: false, block: preCompletion)
        finishWaitLimitTimer = Timer.scheduledTimer(withTimeInterval: finishWaitLimitTime, repeats: false, block: preCompletion)
        self.backgroundUpdateSink = progress.objectWillChange.sink {
            startWaitLimitTimer?.invalidate()
            syncTimer?.invalidate()
            syncTimer = Timer.scheduledTimer(withTimeInterval: syncTime, repeats: false) { timer in
                guard progress.progress.fractionCompleted == 1 || progress.progress.fractionCompleted == 0 else { return }
                preCompletion(timer)
            }
        }
    }
}

extension AppDelegate {
    private func simulator_configure() {
        #if targetEnvironment(simulator)
        let fm = FileManager.default
        fm.urls(for: .documentDirectory, in: .userDomainMask)[0].deletingLastPathComponent().path.log(as: .debug)
        fm.containerURL(forSecurityApplicationGroupIdentifier: "group.com.saturdayapps.WaterMe")!.path.log(as: .debug)
        #endif
    }
}

import ServerlessLogger

private class LoggerErrorDelegate: ServerlessLoggerErrorDelegate {
    func logger(with configuration: ServerlessLoggerConfigurationProtocol, produced error: Logger.Error) {
        // Print ServerlessLogger Error in DEBUG mode only
        assert({ print("LoggerErrorDelegate.error: \(error)"); return true }())
    }
}
