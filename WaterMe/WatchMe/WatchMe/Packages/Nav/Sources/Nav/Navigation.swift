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
import Umbrella

public struct Navigation {
    public enum State: Codable {
        case rootアError(Error)
        case rootアList
        case rootアListアError(Error)
        case rootアListアSettings
        case rootアListアMenu(ReminderAndVesselInput)
        case rootアListアWatering(WateringInput)
        case rootアListアSummary(ReminderInput)
        case rootアListアReminderEdit(ReminderInput)
        case rootアListアVesselEdit(VesselInput)
        case rootアListアVesselEditアReminderEdit(ReminderAndVesselInput)
        case rootアListアVesselEditアEmoji(VesselInput)
    }
    
    public static func root() -> Navigation {
        return Navigation(.rootアList)
    }
    
    public mutating func reset() {
        self.state = .rootアList
    }
    
    public init(_ state: State) {
        self.state = state
        switch state {
        case .rootアError(let v):
            self.isRootアError = v
        case .rootアList:
            self.isRootアList = true
        case .rootアListアError(let v):
            self.isRootアListアError = v
        case .rootアListアSettings:
            self.isRootアListアSettings = true
        case .rootアListアMenu(let v):
            self.isRootアListアMenu = v
        case .rootアListアWatering(let v):
            self.isRootアListアWatering = v
        case .rootアListアSummary(let v):
            self.isRootアListアSummary = v
        case .rootアListアReminderEdit(let v):
            self.isRootアListアReminderEdit = v
        case .rootアListアVesselEdit(let v):
            self.isRootアListアVesselEdit = v
        case .rootアListアVesselEditアReminderEdit(let v):
            self.isRootアListアVesselEdit = .init(v.vesselID)
            self.isRootアListアVesselEditアReminderEdit = v
        case .rootアListアVesselEditアEmoji(let v):
            self.isRootアListアVesselEdit = .init(v.vesselID)
            self.isRootアListアVesselEditアEmoji = v
        }
    }
    
    public var state: State {
        didSet {
            self = .init(self.state)
        }
    }
    
    public var isRootアError: Error? {
        didSet {
            guard self.isRootアError == nil else { return }
            self.reset()
        }
    }
    public var isRootアList = false {
        didSet {
            guard self.isRootアList == false else { return }
            self.reset()
        }
    }
    public var isRootアListアError: Error? {
        didSet {
            guard self.isRootアListアError == nil else { return }
            self.reset()
        }
    }
    public var isRootアListアSettings = false {
        didSet {
            guard self.isRootアListアSettings == false else { return }
            self.reset()
        }
    }
    // TODO: Hack needed for confirmation dialog
    public var isRootアListアMenu: ReminderAndVesselInput? {
        didSet {
            guard self.isRootアListアMenu == nil else { return }
            self.reset()
        }
    }
    public var isRootアListアWatering: WateringInput? {
        didSet {
            guard self.isRootアListアWatering == nil else { return }
            self.reset()
        }
    }
    public var isRootアListアSummary: ReminderInput? {
        didSet {
            guard self.isRootアListアSummary == nil else { return }
            self.reset()
        }
    }
    public var isRootアListアReminderEdit: ReminderInput? {
        didSet {
            guard self.isRootアListアReminderEdit == nil else { return }
            self.reset()
        }
    }
    public var isRootアListアVesselEdit: VesselInput? {
        didSet {
            guard self.isRootアListアVesselEdit == nil else { return }
            self.reset()
        }
    }
    public var isRootアListアVesselEditアReminderEdit: ReminderAndVesselInput? {
        didSet {
            guard self.isRootアListアVesselEditアReminderEdit == nil else { return }
            self.state = self.isRootアListアVesselEdit.map { .rootアListアVesselEdit($0) } ?? .rootアList
        }
    }
    public var isRootアListアVesselEditアEmoji: VesselInput? {
        didSet {
            guard self.isRootアListアVesselEditアEmoji == nil else { return }
            self.state = self.isRootアListアVesselEdit.map { .rootアListアVesselEdit($0) } ?? .rootアList
        }
    }
    public mutating func append(_ error: Error) {
        switch self.state {
        case .rootアError:
            break // TODO: log ignore
        case .rootアList:
            self.state = .rootアListアError(error)
        case .rootアListアError(_):
            break // TODO: log ignore
        case .rootアListアSettings:
            break // TODO: log ignore
        case .rootアListアMenu(_):
            break // TODO: log ignore
        case .rootアListアWatering(_):
            break // TODO: log ignore
        case .rootアListアSummary(_):
            break // TODO: log ignore
        case .rootアListアReminderEdit(_):
            break // TODO: log ignore
        case .rootアListアVesselEdit(_):
            break // TODO: log ignore
        case .rootアListアVesselEditアReminderEdit(_):
            break // TODO: log ignore
        case .rootアListアVesselEditアEmoji(_):
            break // TODO: log ignore
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
    // TODO: Add error options here
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
