//
//  RLM_ReminderWrapper.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/05/20.
//  Copyright © 2020 Saturday Apps.
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

import RealmSwift

internal struct RLM_ReminderWrapper: Reminder {
    internal var wrappedObject: RLM_Reminder
    internal init(_ wrappedObject: RLM_Reminder) {
        self.vessel = wrappedObject.vessel.map { RLM_ReminderVesselWrapper($0) }
        self.wrappedObject = wrappedObject
    }

    var kind: ReminderKind { self.wrappedObject.kind }
    var uuid: String { self.wrappedObject.uuid }
    var interval: Int { self.wrappedObject.interval }
    var isEnabled: Bool { self.wrappedObject.isEnabled }
    var note: String? { self.wrappedObject.note }
    var nextPerformDate: Date? { self.wrappedObject.nextPerformDate }
    var lastPerformDate: Date? { self.wrappedObject.performed.last?.date }
    var isModelComplete: ModelCompleteError? { self.wrappedObject.isModelComplete }
    let vessel: ReminderVessel?

    func observe(_ block: @escaping (ReminderChange) -> Void) -> ObservationToken {
        return self.wrappedObject.observe { realmChange in
            switch realmChange {
            case .error(let error):
                error.log()
                block(.error(.read))
            case .change:
                block(.change(()))
            case .deleted:
                block(.deleted)
            }
        }
    }

    func observePerforms(_ block: @escaping (ReminderPerformCollectionChange) -> Void) -> ObservationToken {
        fatalError("Not Implemented")
    }
}
