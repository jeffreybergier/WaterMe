//
//  Created by Jeffrey Bergier on 2022/02/18.
//  Copyright © 2021 Saturday Apps.
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

import SwiftUI
import Umbrella

internal struct Noun {
    internal static let appTitle: LocalizationKey          = "Label.WaterMe"
    internal static let reminder: LocalizationKey          = "Label.Reminder"
    internal static let plant: LocalizationKey             = "Label.Plant"
    internal static let name: LocalizationKey              = "Label.Name"
    internal static let myPlant: LocalizationKey           = "Label.My Plant"
    internal static let lastPerformed: LocalizationKey     = "Label.Last Performed"
    internal static let remindEvery: LocalizationKey       = "Label.Remind Every"
    internal static let reminderKindShort: LocalizationKey = "Label.Kind.Short"
    internal static let reminderKindLong: LocalizationKey  = "Label.Kind.Long"
    internal static let dueNext: LocalizationKey           = "Label.Due Next"
    internal static let never: LocalizationKey             = "Label.Never"
    internal static let now: LocalizationKey               = "Label.Now"
    internal static let mistShort: LocalizationKey         = "Label.Mist.Short"
    internal static let mistLong: LocalizationKey          = "Label.Mist.Long"
    internal static let moveShort: LocalizationKey         = "Label.Move.Short"
    internal static let moveLong: LocalizationKey          = "Label.Move.Long"
    internal static let trimShort: LocalizationKey         = "Label.Trim.Short"
    internal static let trimLong: LocalizationKey          = "Label.Trim.Long"
    internal static let fertilizeShort: LocalizationKey    = "Label.Fertilize.Short"
    internal static let fertilizeLong: LocalizationKey     = "Label.Fertilize.Long"
    internal static let waterShort: LocalizationKey        = "Label.Water.Short"
    internal static let waterLong: LocalizationKey         = "Label.Water.Long"
    internal static let other: LocalizationKey             = "Label.Other"
    internal static let moveTo: LocalizationKey            = "Label.Move to"
    internal static let notes: LocalizationKey             = "Label.Notes"
    internal static let late: LocalizationKey              = "Label.Late"
    internal static let today: LocalizationKey             = "Label.Today"
    internal static let tomorrow: LocalizationKey          = "Label.Tomorrow"
    internal static let thisWeek: LocalizationKey          = "Label.This Week"
    internal static let later: LocalizationKey             = "Label.Later"
    internal static let paused: LocalizationKey            = "Label.Paused"
    internal static let editPlant: LocalizationKey         = "Label.Edit Plant"
    internal static let editReminder: LocalizationKey      = "Label.Edit Reminder"
    internal static let photo: LocalizationKey             = "Label.Photo"
    internal static let reminders: LocalizationKey         = "Label.Reminders"
    internal static let plantName: LocalizationKey         = "Label.Plant Name"
    internal static let defaultEmoji: LocalizationKey      = "Label.🌸"
    internal static let every: LocalizationKey             = "Label.Every"
    internal static let everyColon: LocalizationKey        = "Label.Every:"
    internal static let description: LocalizationKey       = "Label.Description"
    internal static let details: LocalizationKey           = "Label.Details"
    internal static let notifications: LocalizationKey     = "Label.Notifications"
    internal static let permissionDenied: LocalizationKey  = "Label.Permission Denied"
    internal static let error: LocalizationKey             = "Label.Error"
    internal static let errorDeleting: LocalizationKey     = "Label.Error Deleting"
    internal static let errorLoading: LocalizationKey      = "Label.Error Loading"
    internal static let errorSaving: LocalizationKey       = "Label.Error Saving"
    internal static let emptyString: LocalizationKey       = ""
    internal static let settings: LocalizationKey          = "Label.Settings"
    internal static let checkForUpdates: LocalizationKey   = "Label.Check for Updates"
    internal static let remindFor: LocalizationKey         = "Label.Remind for"
    internal static let days7: LocalizationKey    = "Label.7 Days"
    internal static let days8: LocalizationKey    = "Label.8 Days"
    internal static let days9: LocalizationKey    = "Label.9 Days"
    internal static let days10: LocalizationKey   = "Label.10 Days"
    internal static let days11: LocalizationKey   = "Label.11 Days"
    internal static let days12: LocalizationKey   = "Label.12 Days"
    internal static let days13: LocalizationKey   = "Label.13 Days"
    internal static let days14: LocalizationKey   = "Label.14 Days"
    internal static let days15: LocalizationKey   = "Label.15 Days"
    internal static let days16: LocalizationKey   = "Label.16 Days"
    internal static let days17: LocalizationKey   = "Label.17 Days"
    internal static let days18: LocalizationKey   = "Label.18 Days"
    internal static let days19: LocalizationKey   = "Label.19 Days"
    internal static let days20: LocalizationKey   = "Label.20 Days"
    internal static let days21: LocalizationKey   = "Label.21 Days"
    internal static let remindAt: LocalizationKey = "Label.Remind at"
    internal static let time4: LocalizationKey    = "Label.4 am"
    internal static let time5: LocalizationKey    = "Label.5 am"
    internal static let time6: LocalizationKey    = "Label.6 am"
    internal static let time7: LocalizationKey    = "Label.7 am"
    internal static let time8: LocalizationKey    = "Label.8 am"
    internal static let time9: LocalizationKey    = "Label.9 am"
    internal static let time10: LocalizationKey   = "Label.10 am"
    internal static let time11: LocalizationKey   = "Label.11 am"
    internal static let time12: LocalizationKey   = "Label.Noon"
    internal static let time13: LocalizationKey   = "Label.1 pm"
    internal static let time14: LocalizationKey   = "Label.2 pm"
    internal static let time15: LocalizationKey   = "Label.3 pm"
    internal static let time16: LocalizationKey   = "Label.4 pm"
    internal static let time17: LocalizationKey   = "Label.5 pm"
    internal static let time18: LocalizationKey   = "Label.6 pm"
    internal static let time19: LocalizationKey   = "Label.7 pm"
    internal static let time20: LocalizationKey   = "Label.8 pm"
    internal static let time21: LocalizationKey   = "Label.9 pm"
    internal static let time22: LocalizationKey   = "Label.10 pm"
    internal static let time23: LocalizationKey   = "Label.11 pm"
    internal static let syncViaiCloud: LocalizationKey       = "Label.Sync via iCloud"
    internal static let askForNotifications: LocalizationKey = "Label.Ask for Notifications"
    internal static let increaseContrast: LocalizationKey    = "Label.Increase Contrast"
    internal static let darkMode: LocalizationKey            = "Label.Dark Mode"
    internal static let changeWithSystem: LocalizationKey    = "Label.Change with System"
    internal static let alwaysLight: LocalizationKey         = "Label.Always Light"
    internal static let alwaysDark: LocalizationKey          = "Label.Always Dark"
}
