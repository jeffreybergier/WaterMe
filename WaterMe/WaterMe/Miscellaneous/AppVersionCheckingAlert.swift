//
//  AppVersionCheckingAlert.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/16/18.
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

import UIKit
import Store
import Calculate

extension UIAlertController {

    enum UpdateAction {
        case update, cancel
    }

    // swiftlint:disable:next function_body_length
    class func newAppVersionCheckAlert(_ completion: @escaping (UIViewController?) -> Void,
                                       _ actionHandler: @escaping (UpdateAction) -> Void)
    {
        // Step 1: Make sure the user has not disabled update checking from Settings.app
        guard UserDefaults.standard.checkForUpdatesOnLaunch else {
            completion(nil)
            return
        }

        // Step 2: Get the Bundle Version of the App
        let bundle = Bundle(for: AppDelegate.self)
        guard let bundleVersion = AppVersion.fetchFromBundle() else {
            completion(nil)
            return
        }

        // Step 3: Get the App Store Version of the App
        AppVersion.fetchFromAppStore { tuple in
            guard let tuple = tuple else {
                completion(nil)
                return
            }
            let (appStoreVersion, minimumOSVersion) = tuple

            // Step 4: Make sure the minimum OS version is lower than the current system
            // Otherwise its rude and annoying to show update alerts because
            // the user literally can't get the update.
            guard
                let bundleOSVersion = AppVersion(versionString: UIDevice.current.systemVersion),
                bundleOSVersion >= minimumOSVersion
            else {
                completion(nil)
                return
            }

            // Step 5: See how many times we have presented an alert for this
            // App Store version before. We only want to show the alert twice
            // for any given version.
            let shownDates = UserDefaults.standard.updateDisplayDates(forAppStoreVersion: appStoreVersion)
            switch shownDates.count {
            case 1:
                // If we have already shown the alert one time, then we need to make sure
                // we don't show it again for at least a week from the original showing.
                // if it is over a week since we last showed it, fallthrough to the 0 case
                guard
                    let originallyShownDate = shownDates.first,
                    Calendar.current.enoughTimeHasElapsedSinceOriginallyShownDate(originallyShownDate)
                else {
                    completion(nil)
                    return
                }
                fallthrough
            case 0:
                // If we have shown it 0 times, then create the alert and show it
                let preActionHandler = {
                    UserDefaults.standard.markUpdateDisplayed(forAppStoreVersion: appStoreVersion)
                }
                let isTestFlightInstall = bundle.isTestFlightInstall
                let alert = self.updateAvailableAlertByComparing(appStoreVersion: appStoreVersion,
                                                                 bundleVersion: bundleVersion,
                                                                 isTestFlightInstall: isTestFlightInstall,
                                                                 preActionHandler: preActionHandler,
                                                                 actionHandler: actionHandler)
                completion(alert)
                return
            default:
                // if we have shown the alert more than 2 times, then we don't want to show it any more
                completion(nil)
                return
            }
        }
    }

    private class func updateAvailableAlertByComparing(appStoreVersion: AppVersion,
                                                       bundleVersion: AppVersion,
                                                       isTestFlightInstall: Bool,
                                                       preActionHandler: @escaping () -> Void,
                                                       actionHandler: @escaping (UpdateAction) -> Void) -> UIAlertController?
    {
        if isTestFlightInstall {
            // If the currently running app is a TestFlight build
            // Then we need to alert the user if the AppStore version
            // EXCEEDS -OR- MATCHES the bundle version.
            //
            // Because that means the version is out of beta and should
            // be moved off of testflight
            guard appStoreVersion >= bundleVersion else { return nil }
            return UIAlertController(newUpdateAvailableAlertForTestFlight: true,
                                     preActionHandler: preActionHandler,
                                     actionHandler: actionHandler)
        } else {
            // If its not a testflight build, then we only care if the appstore
            // version EXCEEDS the bundle version
            guard appStoreVersion > bundleVersion else { return nil }
            return UIAlertController(newUpdateAvailableAlertForTestFlight: false,
                                     preActionHandler: preActionHandler,
                                     actionHandler: actionHandler)
        }
    }

    private convenience init(newUpdateAvailableAlertForTestFlight forTestFlight: Bool,
                             preActionHandler: @escaping () -> Void,
                             actionHandler: @escaping (UpdateAction) -> Void)
    {
        switch forTestFlight {
        case true:
            self.init(title: LocalizedString.updateAvailableAlertTitle,
                      message: LocalizedString.updateAvailableTestFlightAlertMessage,
                      preferredStyle: .alert)
        case false:
            self.init(title: LocalizedString.updateAvailableAlertTitle,
                      message: LocalizedString.updateAvailableAlertMessage,
                      preferredStyle: .alert)
        }
        let appStore = UIAlertAction(title: LocalizedString.updateAvailableButtonTitleOpenAppStore, style: .default)
        { _ in
            Analytics.log(event: Analytics.Event.updateAvailableAppStore)
            preActionHandler()
            actionHandler(.update)
        }
        let cancel = UIAlertAction(title: LocalizedString.buttonTitleDismiss, style: .cancel)
        { _ in
            Analytics.log(event: Analytics.Event.updateAvailableDismiss)
            preActionHandler()
            actionHandler(.cancel)
        }
        self.addAction(appStore)
        self.addAction(cancel)
    }
}

extension UserDefaults {

    fileprivate static let kAppVersionDisplayDatePrefix = "kAppVersionDisplayDatePrefixKey"

    private static func key(for version: AppVersion) -> String {
        return kAppVersionDisplayDatePrefix + ":" + version.versionString
    }

    fileprivate func updateDisplayDates(forAppStoreVersion version: AppVersion) -> [Date] {
        let key = type(of: self).key(for: version)
        let dates = self.object(forKey: key) as? [Date]
        return dates ?? []
    }

    fileprivate func markUpdateDisplayed(forAppStoreVersion version: AppVersion) {
        let existingDates = self.updateDisplayDates(forAppStoreVersion: version)
        let key = type(of: self).key(for: version)
        self.set(existingDates + [Date()], forKey: key)
    }
}

fileprivate extension Calendar {
    func enoughTimeHasElapsedSinceOriginallyShownDate(_ originallyShownDate: Date) -> Bool {
        let now = Date()
        guard
            let oneWeekAfterShownDate = self.date(byAdding: .weekOfYear,
                                                    value: 1,
                                                    to: originallyShownDate),
            now >= oneWeekAfterShownDate
        else { return false }
        return true
    }
}
