//
//  Created by Jeffrey Bergier on 2022/02/23.
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
import Umbrella
import Model
import Style

@propertyWrapper
public struct ReminderEdit: DynamicProperty {
    
    public struct Value {
        public var title: LocalizationKey = Label.editReminder
        public var sectionTitleDetails: LocalizationKey = Label.details
        public var sectionTitleNotifications: LocalizationKey = Label.notifications
        public var sectionTitleNotes: LocalizationKey = Label.notes
        public var sectionTitleLastPerformed: LocalizationKey = Label.lastPerformed
        public var subsectionTitleInterval: LocalizationKey = Label.every
        public var subsectionTitleKind: LocalizationKey
        public var subsectionTitleNotifications: LocalizationKey
        public var subsectionPlaceholderMoveTo: LocalizationKey = Label.moveTo
        public var subsectionPlaceholderDescription: LocalizationKey = Label.description
        public var subsectionPlaceholderLastPerformed: LocalizationKey = Label.never
    }
    
    private static let timeAgoFormatter = Formatter.newTimeAgoFormatter
    private static let reminderIntervalFormatter = Formatter.newReminderIntervalFormatter
    
    @SizeClass private var size
    @EnvironmentBundle<LocalizeBundle> private var bundle
    
    public init() {}
    
    public var wrappedValue: (KeyPath<Value, LocalizationKey>) -> LocalizedString {
        let value = Value(
            subsectionTitleKind: _subsectionTitleKind,
            subsectionTitleNotifications: _subsectionTitleNotifications
        )
        return { self.bundle.localized(key: value[keyPath: $0]) }
        
    }
    
    // TODO: Find workaround for this
    // It would be nice if I could somehow do this via `Value`
    public func subsectionDataInterval(_ interval: Int) -> LocalizedString {
        ReminderEdit.reminderIntervalFormatter.string(forDayInterval: interval)
    }
    public func subsectionDataKind(_ kind: Model.ReminderKind) -> LocalizedString {
        self.bundle.localized(key: kind.localizedLong)
    }
    public func subsectionDataLastPerformed(_ date: Date?) -> LocalizedString? {
        ReminderEdit.timeAgoFormatter.timeAgoString(for: date)
    }
    private var _subsectionTitleNotifications: LocalizedString {
        switch self.size.horizontal {
        case .small:
            return Action.pause
        case .medium, .large:
            return Action.pauseNotifications
        }
    }
    private var _subsectionTitleKind: LocalizedString {
        switch self.size.horizontal {
        case .small:
            return Label.reminderKindShort
        case .medium, .large:
            return Label.reminderKindLong
        }
    }
}
