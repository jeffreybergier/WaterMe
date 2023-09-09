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

#if os(watchOS)
public typealias Detail = QuickPerform
#else
public typealias Detail = ReminderGrid
#endif

public struct Root: Codable {
    public var isError: ErrorStorage.Identifier?
    public var detail = Detail()
    public var isAlreadyPresenting: Bool {
        self.isError != nil
    }
}

public struct QuickPerform: Codable {
    public struct Hamburger: Codable {
        public var selection: Reminder.Selection = []
        public var isPresented: Bool = false {
            didSet {
                guard self.isPresented == false else { return }
                self.selection = []
            }
        }
    }
    public var isPresented: Share.Identifier?
    public var isError:        ErrorStorage.Identifier?
    public var vesselEdit      = VesselEdit()
    public var reminderGrid    = ReminderGrid()
    public var hamburgerMenu = Hamburger()
    public var isAlreadyPresenting: Bool {
        return self.isError != nil
        || self.vesselEdit.isPresented != nil
        || self.reminderGrid.isPresented != nil
        || self.hamburgerMenu.isPresented == true

    }
}

public struct ReminderGrid: Codable {
    public var isPresented:     Share.Identifier?
    public var isError:         ErrorStorage.Identifier?
    public var vesselEdit:      VesselEdit = .init()
    public var reminderSummary: ReminderSummary = .init()
    public var isHamburgerMenu = false
    public var isAlreadyPresenting: Bool {
        return self.isError != nil
        || self.vesselEdit.isPresented != nil
        || self.reminderSummary.isPresented != nil
        || self.isHamburgerMenu == true
    }
}

public struct ReminderEdit: Codable {
    public var isPresented: Reminder.Identifier?
    public var isError:     ErrorStorage.Identifier?
    public var isAlreadyPresenting: Bool {
        return self.isError != nil
    }
}

public struct VesselEdit: Codable {
    public var isPresented:  Vessel.Identifier?
    public var isError:      ErrorStorage.Identifier?
    public var isPickerMenu: Vessel.Identifier?
    public var isPicker:     PickerKind?
    public var reminderEdit = ReminderEdit()
    public var isAlreadyPresenting: Bool {
        return self.isError != nil
        || self.reminderEdit.isPresented != nil
        || self.isPickerMenu != nil
        || self.isPicker != nil
    }
}

public struct ReminderSummary: Codable {
    public var isPresented: Reminder.Identifier?
    public var isError:     ErrorStorage.Identifier?
    public var reminderEdit = ReminderEdit()
    public var vesselEdit   = VesselEdit()
    public var isAlreadyPresenting: Bool {
        return self.isError != nil
        || self.reminderEdit.isPresented != nil
        || self.vesselEdit.isPresented != nil
    }
}

public enum PickerKind: Int, Codable, Identifiable {
    public var id: Int { self.rawValue }
    case camera, library, emoji, viewPhoto
}
