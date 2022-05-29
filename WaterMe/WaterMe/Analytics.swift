//
//  Analytics.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 15/1/18.
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
import StoreKit
import Foundation

enum Analytics {

    // MARK: Events

    enum Event: String {
        case reviewRequested = "Event.ReviewRequested"
        case stpReloadNotification = "Event.STPReload.Notification"
        case updateAvailableDismiss = "Event.UpdateAvailable.Dismiss"
        case updateAvailableAppStore = "Event.UpdateAvailable.AppStore"
        case notificationSettingsFail = "Error.NotifySettingsLoadFailure"
    }

    // MARK: CRUD Operations

    enum CRUD_Op_R: String {
        case create = "CRUD.R.Create"
        case update = "CRUD.R.Update"
        case delete = "CRUD.R.Delete"
        case pause = "CRUD.R.Pause"
        case performLegacy = "CRUD.R.performLegacy"
        case performDrag = "CRUD.R.performDrag"

        static func extras(count: Int) -> [String: Any] {
            return [
                "count": NSNumber(value: count),
            ]
        }
    }

    enum CRUD_Op_RV: String {
        case create = "CRUD.RV.Create"
        case update = "CRUD.RV.Update"
        case delete = "CRUD.RV.Delete"
    }

    // MARK: Notification Permissions

    enum NotificationPermission: String {
        case scheduleSucceeded = "Notify.Sched.Success"
        case scheduleDeniedBySystem = "Notify.Sched.Denied.Sys"
        case scheduleBadgeIconDeniedBySystem = "Notify.Badge.Sched.Denied.Sys"
        case permissionGranted = "Notify.PermissionGranted"
        case permissionDenied = "Notify.PermissionDenied"
        case permissionIgnored = "Notify.PermissionIgnored"
        case scheduleAlreadyInProgress = "Notify.SchedulingAlreadyInProgress"

        static func extras(forCount count: Int) -> [String: Any] {
            return ["NotifyCount": NSNumber(value: count)]
        }
    }

    // MARK: Core Data Migration

    enum CoreDataMigration: String {
        case migrationComplete = "CDMigration.Complete"
        case migrationPartial = "CDMigration.Partial"
        case migrationSkipped = "CDMigration.Skipped"
        case migrationDeleted = "CDMigration.Deleted"

        static func extras(migrated: Int, total: Int) -> [String: Any] {
            return [
                "migrated": NSNumber(value: migrated),
                "total": NSNumber(value: total),
            ]
        }
    }

    // MARK: Notification Tapped

    enum NotificationAction: String {
        case tapped = "Notify.Tapped"
        case dismissed = "Notify.Dismissed"
        case other = "Notify.Other"
    }

    // MARK: In-App Purchases

    enum IAPOperation: String {
        case loadError = "IAP.LoadError"
        case buyErrorUnknown = "IAP.BuyError.Unknown"
        case buyErrorNetwork = "IAP.BuyError.Network"
        case buyErrorNotAllowed = "IAP.BuyError.NotAllowed"
        case buySuccess = "IAP.BuySuccess"
    }

    // MARK: View Controller Views

    enum VCViewOperation: String {
        case cloudSyncInfo = "VCView.CloudSyncInfo"
        case purchaseThanks = "VCView.PurchaseThanks"
        case coreDataMigration = "VCView.CoreDataMigration"
        case reminderList = "VCView.ReminderList"
        case reminderSummary = "VCView.ReminderSummary"
        case reminderVesselList = "VCView.ReminderVesselList"
        case editReminderVessel = "VCView.EditReminderVessel"
        case editReminder = "VCView.EditReminder"
        case emailDeveloper = "VCView.EmailDeveloper"
        case tipJar = "VCView.TipJar"
        case openSettings = "VCView.OpenSettings"
        case openAppStoreReview = "VCView.OpenAppStoreReview"
        case openAppStore = "VCView.OpenAppStore"
        case errorAlertRealm = "VCView.ErrorAlert.Realm"
        case errorAlertPurchase = "VCView.ErrorAlert.Purchase"
        case alertUpdateAvailable = "VCView.Alert.UpdatedAvailable"
        case viewReminderVesselPhoto = "VCView.ReminderVesselPhoto"
    }

    // MARK: Logging Functions

    static func log(error: Error) { }

    static func log(viewOperation op: VCViewOperation) { }

    static func log<E: RawRepresentable>(event op: E, extras: [String: Any]? = nil) where E.RawValue == String { }

}
