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

public struct Reminder: Identifiable, Hashable, Equatable {

    public struct Identifier: Hashable, Equatable, Codable, RawRepresentable, Identifiable {
        public var id: String { self.rawValue }
        public var rawValue: String
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }

    public var id: Identifier
    public var kind: ReminderKind
    public var kindDescription: String?
    public var interval: Int
    public var isEnabled: Bool
    public var note: String?
    public var nextPerformDate: Date?
    public var lastPerformDate: Date?
    public var isDeleted: Bool
    public var vesselID: Vessel.Identifier?

    public init(id: Identifier,
                kind: ReminderKind? = nil,
                kindDescription: String? = nil,
                interval: Int,
                isEnabled: Bool = true,
                note: String? = nil,
                nextPerformDate: Date? = nil,
                lastPerformDate: Date? = nil,
                isDeleted: Bool = false,
                vesselID: Vessel.Identifier? = nil)
    {
        self.id = id
        self.kind = kind ?? .water
        self.kindDescription = kindDescription
        self.interval = interval
        self.isEnabled = isEnabled
        self.note = note
        self.nextPerformDate = nextPerformDate
        self.lastPerformDate = lastPerformDate
        self.isDeleted = isDeleted
        self.vesselID = vesselID
    }
}
