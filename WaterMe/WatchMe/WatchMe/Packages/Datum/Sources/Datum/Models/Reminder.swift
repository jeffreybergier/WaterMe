//
//  Created by Jeffrey Bergier on 2021/12/31.
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

import Foundation

public struct Reminder: Identifiable, Hashable {
    public var id: String
    public var kind: ReminderKind
    public var interval: Int
    public var isEnabled: Bool
    public var note: String?
    public var nextPerformDate: Date?
    public var lastPerformDate: Date?
//    public var vessel: ReminderVessel? { get }
}

extension Reminder {
    internal init(cd: CD_Reminder) {
        self.kind = cd.kind
        self.id = cd.objectID.uriRepresentation().absoluteString
        self.interval = Int(cd.raw_interval)
        self.isEnabled = cd.raw_isEnabled
        self.note = cd.raw_note
        self.nextPerformDate = cd.raw_nextPerformDate
        self.lastPerformDate = cd.raw_lastPerformDate
    }
}
