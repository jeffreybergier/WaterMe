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

internal enum Noun: LocalizationKey {
    case appTitle            = "Label.WaterMe"
    case reminder            = "Label.Reminder"
    case home                = "Label.Home"
    case libraries           = "Label.Libraries"
    case plant               = "Label.Plant"
    case name                = "Label.Name"
    case myPlant             = "Label.My Plant"
    case lastPerformed       = "Label.Last Performed"
    case remindEvery         = "Label.Remind Every"
    case reminderKindShort   = "Label.Kind.Short"
    case reminderKindLong    = "Label.Kind.Long"
    case dueNext             = "Label.Due Next"
    case never               = "Label.Never"
    case now                 = "Label.Now"
    case mistShort           = "Label.Mist.Short"
    case mistLong            = "Label.Mist.Long"
    case moveShort           = "Label.Move.Short"
    case moveLong            = "Label.Move.Long"
    case trimShort           = "Label.Trim.Short"
    case trimLong            = "Label.Trim.Long"
    case fertilizeShort      = "Label.Fertilize.Short"
    case fertilizeLong       = "Label.Fertilize.Long"
    case waterShort          = "Label.Water.Short"
    case waterLong           = "Label.Water.Long"
    case other               = "Label.Other"
    case moveTo              = "Label.Move to"
    case notes               = "Label.Notes"
    case late                = "Label.Late"
    case today               = "Label.Today"
    case tomorrow            = "Label.Tomorrow"
    case thisWeek            = "Label.This Week"
    case later               = "Label.Later"
    case paused              = "Label.Paused"
    case editPlant           = "Label.Edit Plant"
    case editReminder        = "Label.Edit Reminder"
    case photo               = "Label.Photo"
    case reminders           = "Label.Reminders"
    case plantName           = "Label.Plant Name"
    case emoji               = "Label.Emoji"
    case emojiChoose         = "Label.Choose an Emoji"
    case emojiDefault        = "Label.🌸"
    case every               = "Label.Every"
    case everyColon          = "Label.Every:"
    case description         = "Label.Description"
    case details             = "Label.Details"
    case notifications       = "Label.Notifications"
    case permissionDenied    = "Label.Permission Denied"
    case error               = "Label.Error"
    case errorDeleting       = "Label.Error Deleting"
    case errorLoading        = "Label.Error Loading"
    case errorSaving         = "Label.Error Saving"
    case emptyString         = ""
    case settings            = "Label.Settings"
    case checkForUpdates     = "Label.Check for Updates"
    case remindFor           = "Label.Remind for"
    case days7               = "Label.7 Days"
    case days8               = "Label.8 Days"
    case days9               = "Label.9 Days"
    case days10              = "Label.10 Days"
    case days11              = "Label.11 Days"
    case days12              = "Label.12 Days"
    case days13              = "Label.13 Days"
    case days14              = "Label.14 Days"
    case days15              = "Label.15 Days"
    case days16              = "Label.16 Days"
    case days17              = "Label.17 Days"
    case days18              = "Label.18 Days"
    case days19              = "Label.19 Days"
    case days20              = "Label.20 Days"
    case days21              = "Label.21 Days"
    case remindAt            = "Label.Remind at"
    case time4               = "Label.4 am"
    case time5               = "Label.5 am"
    case time6               = "Label.6 am"
    case time7               = "Label.7 am"
    case time8               = "Label.8 am"
    case time9               = "Label.9 am"
    case time10              = "Label.10 am"
    case time11              = "Label.11 am"
    case time12              = "Label.Noon"
    case time13              = "Label.1 pm"
    case time14              = "Label.2 pm"
    case time15              = "Label.3 pm"
    case time16              = "Label.4 pm"
    case time17              = "Label.5 pm"
    case time18              = "Label.6 pm"
    case time19              = "Label.7 pm"
    case time20              = "Label.8 pm"
    case time21              = "Label.9 pm"
    case time22              = "Label.10 pm"
    case time23              = "Label.11 pm"
    case syncViaiCloud       = "Label.Sync via iCloud"
    case askForNotifications = "Label.Ask for Notifications"
    case increaseContrast    = "Label.Increase Contrast"
    case darkMode            = "Label.Dark Mode"
    case changeWithSystem    = "Label.Change with System"
    case alwaysLight         = "Label.Always Light"
    case alwaysDark          = "Label.Always Dark"
    case noSelection         = "Label.No Selection"
    case itemNotFound        = "Label.Item Not Found"
    case actions             = "Label.Actions"
}
