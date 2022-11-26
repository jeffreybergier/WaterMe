//
//  ReminderVessel+Helpers.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/05/15.
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

import Calculate

public enum ReminderVesselSortOrder {
    case displayName, kind
}

// MARK: Core Data

extension CD_ReminderVessel {
    internal var icon: ReminderVesselIcon? {
        get {
            return ReminderVesselIcon(rawImageData: self.raw_iconImageData,
                                      emojiString: self.raw_iconEmojiString)
        }
        set {
            self.raw_iconImageData = newValue?.dataValue
            self.raw_iconEmojiString = newValue?.stringValue
        }
    }
    internal var kind: ReminderVesselKind {
        get { return ReminderVesselKind(rawValue: self.raw_kindString ?? "-1") ?? .plant }
        set { self.raw_kindString = newValue.rawValue }
    }
}

extension CD_ReminderVessel: ModelCompleteCheckable {
    internal var isModelComplete: ModelCompleteError? {
        let issues: [RecoveryAction] = [
            self.icon == nil ? .reminderVesselMissingIcon : nil,
            self.raw_displayName == nil ? .reminderVesselMissingName : nil,
            (self.raw_reminders?.count ?? 0) <= 0 ? .reminderVesselMissingReminder : nil
            ].compactMap({ $0 })
        if issues.isEmpty {
            return nil
        } else {
            return ModelCompleteError(_actions: issues + [.cancel, .saveAnyway])
        }
    }
}

extension CD_ReminderVessel {
    internal var shortLabelSafeDisplayName: String? {
        return self.raw_displayName?.truncated(to: 20)
    }
}
