//
//  Created by Jeffrey Bergier on 2023/07/15.
//
//  Copyright © 2022 Saturday Apps.
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
import V3Model

public struct Root: Codable {
    public var isError: ErrorStorage.Identifier?
    #if os(watchOS)
    public var root = QuickPerform()
    #else
    public var root = ReminderGrid()
    #endif
    public var isAlreadyPresenting: Bool {
        self.isError != nil
    }
}

public struct QuickPerform: Codable {
    public var isPresented: Share.Identifier?
    public var vesselEdit = VesselEdit()
    public var reminderGrid = ReminderGrid()
    public var isBulkPerformMenu: Reminder.Selection = []
    public var isHamburgerMenu = false
}

public struct ReminderGrid: Codable {
    public var isPresented: Share.Identifier?
}

public struct ReminderEdit: Codable {
    public var isPresented: Reminder.Identifier?
    public var isEditPhotoChooser: Vessel.Selection.Element?
}

public struct VesselEdit: Codable {
    public var isPresented: Vessel.Identifier?
    public var reminderEdit = ReminderEdit()
}
