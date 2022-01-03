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

public struct Navigation {
    public enum State: Codable {
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
    
    public static func root() -> Navigation {
        return Navigation(.rootList)
    }
    
    public mutating func reset() {
        self.state = .rootList
    }
    
    public init(_ state: State) {
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
            self.isListVesselEdit = .init(v.vesselID)
            self.isListVesselEditReminderEdit = v
        case .listVesselEditEmoji(let v):
            self.isListVesselEdit = .init(v.vesselID)
            self.isListVesselEditEmoji = v
        case .listSettings:
            self.isListSettings = true
        case .listError:
            self.isListError = true
        }
    }
    
    public var state: State {
        didSet {
            self = .init(self.state)
        }
    }
    
    public var isRootList = false {
        didSet {
            guard self.isRootList == false else { return }
            self.reset()
        }
    }
    public var isRootError = false {
        didSet {
            guard self.isRootError == false else { return }
            self.reset()
        }
    }
    // TODO: Hack needed for confirmation dialog
    public var isListMenu: Bool = false {
        didSet {
            guard self.isListMenu == false else { return }
            self.reset()
        }
    }
    // TODO: Hack needed for confirmation dialog
    public var isListMenuData: ReminderAndVesselInput? {
        didSet {
            guard self.isListMenuData == nil else { return }
            self.reset()
        }
    }
    public var isListWatering: WateringInput? {
        didSet {
            guard self.isListWatering == nil else { return }
            self.reset()
        }
    }
    public var isListSummary: ReminderInput? {
        didSet {
            guard self.isListSummary == nil else { return }
            self.reset()
        }
    }
    public var isListReminderEdit: ReminderInput? {
        didSet {
            guard self.isListReminderEdit == nil else { return }
            self.reset()
        }
    }
    public var isListVesselEdit: VesselInput? {
        didSet {
            guard self.isListVesselEdit == nil else { return }
            self.reset()
        }
    }
    public var isListVesselEditReminderEdit: ReminderAndVesselInput? {
        didSet {
            guard self.isListVesselEditReminderEdit == nil else { return }
            self.state = self.isListVesselEdit.map { .listVesselEdit($0) } ?? .rootList
        }
    }
    public var isListVesselEditEmoji: VesselInput? {
        didSet {
            guard self.isListVesselEditEmoji == nil else { return }
            self.state = self.isListVesselEdit.map { .listVesselEdit($0) } ?? .rootList
        }
    }
    public var isListSettings = false {
        didSet {
            guard self.isListSettings == false else { return }
            self.reset()
        }
    }
    public var isListError = false {
        didSet {
            guard self.isListError == false else { return }
            self.reset()
        }
    }
}

// MARK: Inputs

public  struct ReminderInput: Codable, Identifiable {
    public var id: Reminder.アイディ { self.reminderID }
    public var reminderID: Reminder.アイディ
    public init(_ reminderID: Reminder.アイディ) {
        self.reminderID = reminderID
    }
}

public  struct VesselInput: Codable, Identifiable {
    public var id: Vessel.アイディ { self.vesselID }
    public var vesselID: Vessel.アイディ
    public init(_ vesselID: Vessel.アイディ) {
        self.vesselID = vesselID
    }
}

public  struct ReminderAndVesselInput: Codable, Identifiable {
    public var id: String { self.vesselID.id + self.reminderID.id }
    public var reminderID: Reminder.アイディ
    public var vesselID: Vessel.アイディ
    public init(_ reminderID: Reminder.アイディ, _ vesselID: Vessel.アイディ) {
        self.reminderID = reminderID
        self.vesselID = vesselID
    }
}

public  struct WateringInput: Codable, Identifiable, Hashable {
    public var id: Int { self.hashValue }
    public var reminderIDs: [Reminder.アイディ]
    public init(_ reminderIDs: [Reminder.アイディ]) {
        self.reminderIDs = reminderIDs
    }
}
