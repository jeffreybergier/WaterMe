//
//  ReminderVessel.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/31/17.
//  Copyright © 2017 Saturday Apps.
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
import RealmSwift

@objc(ReminderVessel)
internal class RLM_ReminderVessel: Object {
    @objc internal dynamic var uuid = UUID().uuidString
    @objc internal dynamic var displayName: String?
    @objc internal dynamic var iconImageData: Data?
    @objc internal dynamic var iconEmojiString: String?
    @objc internal dynamic var bloop = false
    @objc internal dynamic var kindString = ReminderVesselKind.plant.rawValue
    internal let reminders = List<RLM_Reminder>()
    override internal class func primaryKey() -> String {
        return #keyPath(RLM_ReminderVessel.uuid)
    }
}

extension RLM_ReminderVessel {
    static func keyPath(for sortOrder: ReminderVesselSortOrder) -> String {
        switch sortOrder {
        case .displayName:
            return #keyPath(RLM_ReminderVessel.displayName)
        case .kind:
            return #keyPath(RLM_Reminder.kindString)
        }
    }
}
