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

import SwiftUI
import Model

internal struct Navigation {
    internal enum State: Codable {
        case rootList
        case rootError
        case listMenu(ReminderAndVesselInput)
        case listWatering(WateringInput)
        case listSummary(ReminderInput)
        case listReminderEdit(ReminderInput)
        case listVesselEdit(VesselInput)
        case listVesselEditReminderEdit(ReminderAndVesselInput)
        case listVesselEditEmoji(VesselInput)
        case listSettings
        case listError
    }
    
    static func root() -> Navigation {
        return Navigation(.rootList)
    }
    
    mutating func reset() {
        self.state = .rootList
    }
    
    init(_ state: State) {
        self.state = state
        switch state {
        case .rootList:
            self.isRootList = true
        case .rootError:
            self.isRootError = true
        case .listMenu(let v):
            self.isListMenu = true
            self.isListMenuData = v
        case .listWatering(let v):
            self.isListWatering = v
        case .listSummary(let v):
            self.isListSummary = v
        case .listReminderEdit(let v):
            self.isListReminderEdit = v
        case .listVesselEdit(let v):
            self.isListVesselEdit = v
        case .listVesselEditReminderEdit(let v):
            self.isListVesselEdit = .init(vesselID: v.vesselID)
            self.isListVesselEditReminderEdit = v
        case .listVesselEditEmoji(let v):
            self.isListVesselEditEmoji = v
        case .listSettings:
            self.isListSettings = true
        case .listError:
            self.isListError = true
        }
    }
    
    var state: State {
        didSet {
            self = .init(self.state)
        }
    }
    
    var isRootList = false {
        didSet {
            guard self.isRootList == false else { return }
            self.reset()
        }
    }
    var isRootError = false {
        didSet {
            guard self.isRootError == false else { return }
            self.reset()
        }
    }
    var isListMenu: Bool = false {
        didSet {
            guard self.isListMenu == false else { return }
            self.reset()
        }
    }
    var isListMenuData: ReminderAndVesselInput? {
        didSet {
            guard self.isListMenuData == nil else { return }
            self.reset()
        }
    }
    var isListWatering: WateringInput? {
        didSet {
            guard self.isListWatering == nil else { return }
            self.reset()
        }
    }
    var isListSummary: ReminderInput? {
        didSet {
            guard self.isListSummary == nil else { return }
            self.reset()
        }
    }
    var isListReminderEdit: ReminderInput? {
        didSet {
            guard self.isListReminderEdit == nil else { return }
            self.reset()
        }
    }
    var isListVesselEdit: VesselInput? {
        didSet {
            guard self.isListVesselEdit == nil else { return }
            self.reset()
        }
    }
    var isListVesselEditReminderEdit: ReminderAndVesselInput? {
        didSet {
            guard self.isListVesselEditReminderEdit == nil else { return }
            self.state = .listVesselEdit(self.isListVesselEdit!)
        }
    }
    var isListVesselEditEmoji: VesselInput? {
        didSet {
            guard self.isListVesselEditEmoji == nil else { return }
            self.state = .listVesselEdit(self.isListVesselEdit!)
        }
    }
    var isListSettings = false {
        didSet {
            guard self.isListSettings == false else { return }
            self.reset()
        }
    }
    var isListError = false {
        didSet {
            guard self.isListError == false else { return }
            self.reset()
        }
    }
}

// MARK: Inputs

internal struct ReminderInput: Codable, Identifiable {
    var id: Reminder.アイディ { self.reminderID }
    var reminderID: Reminder.アイディ
}

internal struct VesselInput: Codable, Identifiable {
    var id: Vessel.アイディ { self.vesselID }
    var vesselID: Vessel.アイディ
}

internal struct ReminderAndVesselInput: Codable, Identifiable {
    var id: String { self.vesselID.id + self.reminderID.id }
    var reminderID: Reminder.アイディ
    var vesselID: Vessel.アイディ
}

internal struct WateringInput: Codable, Identifiable, Hashable {
    var id: Int { self.hashValue }
    var reminderIDs: [Reminder.アイディ]
}
