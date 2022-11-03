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
import CoreData

extension Reminder {
    internal init(cd: CD_Reminder) {
        self.init(id: .init(cd.objectID),
                  kind: .init(rawValue: cd.raw_kindString ?? "-1") ?? .water,
                  kindDescription: cd.raw_descriptionString,
                  interval: Int(cd.raw_interval),
                  isEnabled: cd.raw_isEnabled,
                  note: cd.raw_note,
                  nextPerformDate: cd.raw_nextPerformDate,
                  lastPerformDate: cd.raw_lastPerformDate,
                  // TODO: Hack that might not work correctly in all cases
                  isDeleted: cd.managedObjectContext == nil,
                  vesselID: (cd.raw_vessel?.objectID.uriRepresentation().absoluteString).map { .init($0) })
    }
}

extension Reminder.アイディ {
    internal init(_ objectID: NSManagedObjectID) {
        self.init(objectID.uriRepresentation().absoluteString)
    }
}
