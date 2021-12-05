//
//  RLM_ReminderVesselWrapper.swift
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

internal struct RLM_ReminderVesselWrapper: ReminderVessel {
    internal let wrappedObject: RLM_ReminderVessel
    internal init(_ wrappedObject: RLM_ReminderVessel) {
        self.wrappedObject = wrappedObject
    }

    public var uuid: String { self.wrappedObject.uuid }
    public var displayName: String? { self.wrappedObject.displayName }
    public var icon: ReminderVesselIcon? { self.wrappedObject.icon }
    public var kind: ReminderVesselKind { self.wrappedObject.kind }
    public var isModelComplete: ModelCompleteError? { self.wrappedObject.isModelComplete }
    public var shortLabelSafeDisplayName: String? { self.wrappedObject.shortLabelSafeDisplayName }
}

extension RLM_ReminderVesselWrapper {
    func observe(_ block: @escaping (ReminderVesselChange) -> Void) -> ObservationToken {
        return self.wrappedObject.observe { realmChange in
            switch realmChange {
            case .error:
                block(.error(.read))
            case .change(let properties):
                let changedDisplayName = RLM_ReminderVessel.propertyChangesContainDisplayName(properties)
                let changedIconEmoji = RLM_ReminderVessel.propertyChangesContainIconEmoji(properties)
                let changedReminders = RLM_ReminderVessel.propertyChangesContainReminders(properties)
                let changedPointlessBloop = RLM_ReminderVessel.propertyChangesContainPointlessBloop(properties)
                block(.change(.init(changedDisplayName: changedDisplayName,
                                    changedIconEmoji: changedIconEmoji,
                                    changedReminders: changedReminders,
                                    changedPointlessBloop: changedPointlessBloop)))
            case .deleted:
                block(.deleted)
            }
        }
    }

    func observeReminders(_ block: @escaping (ReminderCollectionChange) -> Void) -> ObservationToken {
        return self.wrappedObject.reminders.observe { realmChange in
            switch realmChange {
            case .initial(let data):
                block(.initial(data: AnyCollection(RLM_ReminderCollection(AnyRealmCollection(data)))))
            case .update(_, let deletions, let insertions, let modifications):
                block(.update(.init(insertions: insertions, deletions: deletions, modifications: modifications)))
            case .error:
                block(.error(error: .read))
            }
        }
    }
}
