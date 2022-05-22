//
//  Created by Jeffrey Bergier on 2022/02/18.
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
import Style
import Umbrella
import Model

@propertyWrapper
public struct ReminderSummary: DynamicProperty {
    
    public struct Value {
        public var title: LocalizationKey = Label.reminder
        public var buttonDismiss: LocalizationKey = Action.dismiss
        public var buttonEditPlant: LocalizationKey = Action.editPlant
        public var buttonEditReminder: LocalizationKey = Action.editReminder
        public var buttonMarkDone: LocalizationKey
        public var sectionReminder: LocalizationKey = Label.reminder
        public var sectionVessel: LocalizationKey = Label.plant
        public var sectionNotes: LocalizationKey = Label.notes
        public var subsectionName: LocalizationKey = Label.name
        public var subsectionLastPerformed: LocalizationKey = Label.lastPerformed
        public var subsectionRemindEvery: LocalizationKey = Label.remindEvery
        public var subsectionKind: LocalizationKey = Label.reminderKindShort
        public var subsectionPlaceholderKind: LocalizationKey = Label.other
        public var subsectionDueNext: LocalizationKey = Label.dueNext
        public var subsectionMoveTo: LocalizationKey = Label.moveTo
        public var subsectionDataNoName: LocalizationKey = Label.myPlant
        public var subsectionDataNever: LocalizationKey = Label.never
        public var subsectionDataNow: LocalizationKey = Label.now
    }
    
    private static let timeAgoFormatter = Formatter.newTimeAgoFormatter
    private static let reminderIntervalFormatter = Formatter.newReminderIntervalFormatter
    private static let dueDateFormatter = Formatter.newDueDateFormatter
    
    @SizeClass private var size
    @EnvironmentBundle<LocalizeBundle> private var bundle
    
    public init() {}
        
    public var wrappedValue: (KeyPath<Value, LocalizationKey>) -> LocalizedString {{
        let value = Value(buttonMarkDone: self.markDone)
        return self.bundle.localized(key: value[keyPath: $0])
    }}
    
    // TODO: Find workaround for this
    // It would be nice if I could somehow do this via `Value`
    public func subsectionDataLastPerformed(_ date: Date?) -> LocalizedString? {
        ReminderSummary.timeAgoFormatter.timeAgoString(for: date)
    }
    public func subsectionDataRemindEvery(_ interval: Int) -> LocalizedString {
        ReminderSummary.reminderIntervalFormatter.string(forDayInterval: interval)
    }
    public func subsectionDataDueNext(_ date: Date?) -> LocalizedString? {
        date.map { ReminderSummary.dueDateFormatter.string(from: $0) }
    }
    public func subsectionDataKind(_ kind: Model.ReminderKind) -> LocalizedString {
        self.bundle.localized(key: kind.localizedLong)
    }
    private var markDone: LocalizationKey {
        switch self.size.horizontal {
        case .small:
            return Action.markDoneGeneric
        case .medium, .large:
            return Action.markDoneReminder
        }
    }
}
