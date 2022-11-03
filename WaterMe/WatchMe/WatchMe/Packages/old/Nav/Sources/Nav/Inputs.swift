//
//  Created by Jeffrey Bergier on 2022/01/02.
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

import Model

// MARK: Inputs

public struct ReminderInput: Codable {
    public var reminderID: Reminder.アイディ
    public init(_ reminderID: Reminder.アイディ) {
        self.reminderID = reminderID
    }
}

public struct VesselInput: Codable {
    public var vesselID: Vessel.アイディ
    public init(_ vesselID: Vessel.アイディ) {
        self.vesselID = vesselID
    }
}

public struct ReminderAndVesselInput: Codable {
    public var reminderID: Reminder.アイディ
    public var vesselID: Vessel.アイディ
    public init(_ reminderID: Reminder.アイディ, _ vesselID: Vessel.アイディ) {
        self.reminderID = reminderID
        self.vesselID = vesselID
    }
}

public struct WateringInput: Codable {
    public var reminderIDs: [Reminder.アイディ]
    public init(_ reminderIDs: [Reminder.アイディ]) {
        self.reminderIDs = reminderIDs
    }
}
