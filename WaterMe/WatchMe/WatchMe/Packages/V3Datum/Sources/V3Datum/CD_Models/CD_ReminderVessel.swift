//
//  CD_ReminderVessel.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/05/21.
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

import CoreData
import V3Model

public enum ReminderVesselSortOrder {
    case displayName, kind
}

@objc(CD_ReminderVessel)
internal class CD_ReminderVessel: CD_Base {

    override class var entityName: String { "CD_ReminderVessel" }
    class var request: NSFetchRequest<CD_ReminderVessel> {
        NSFetchRequest<CD_ReminderVessel>(entityName: self.entityName)
    }

    override func awakeFromInsert() {
        super.awakeFromInsert()
        self.raw_kindString = "" // TODO: VesselKind.plant.rawValue
    }

    override func willSave() {
        super.willSave()
        /* TODO:
        if let displayName = self.raw_displayName, displayName.nonEmptyString == nil {
            self.raw_displayName = nil
        }
         */
    }
}

extension CD_ReminderVessel {
    static func sortDescriptor(for sortOrder: ReminderVesselSortOrder,
                               ascending: Bool) -> NSSortDescriptor
    {
        switch sortOrder {
        case .displayName:
            return .init(key: #keyPath(CD_ReminderVessel.raw_displayName), ascending: ascending)
        case .kind:
            return .init(key: #keyPath(CD_ReminderVessel.raw_kindString), ascending: ascending)
        }
    }
}

extension Vessel.Identifier {
    internal init(_ id: NSManagedObjectID) {
        self.init(rawValue: id.uriRepresentation().absoluteString)
    }
    internal init?(_ id: NSManagedObjectID?) {
        guard let id else { return nil }
        self.init(rawValue: id.uriRepresentation().absoluteString)
    }
}

extension Vessel {
    internal init(_ cd: CD_ReminderVessel) {
        self.init(
            id: .init(cd.objectID),
            displayName: cd.raw_displayName,
            icon: .init(cleanData: cd.raw_iconImageData,
                        cleanString: cd.raw_iconEmojiString),
            kind: .init(rawValue: cd.raw_kindString ?? ""),
            isDeleted: cd.isDeleted
        )
    }
}
