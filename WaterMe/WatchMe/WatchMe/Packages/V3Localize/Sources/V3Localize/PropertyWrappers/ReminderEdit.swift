//
//  Created by Jeffrey Bergier on 2022/11/13.
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

@propertyWrapper
public struct ReminderEdit: DynamicProperty {
    
    public struct Value {
        
        private var never:        LocalizedString
        public var title:         LocalizedString
        public var delete:        ActionLocalization
        public var notFound:      ActionLocalization
        public var kind:          ActionLocalization
        public var kindWater:     ActionLocalization
        public var kindFertilize: ActionLocalization
        public var kindTrim:      ActionLocalization
        public var kindMist:      ActionLocalization
        public var kindMove:      ActionLocalization
        public var kindOther:     ActionLocalization
        public var interval:      ActionLocalization
        public var pause:         ActionLocalization
        public var reminder:      ActionLocalization
        public var notes:         ActionLocalization
        public var lastPerformed: ActionLocalization
        
        internal init(_ b: LocalizeBundle) {
            self.title         = b.localized(key: Noun.editReminder.rawValue)
            self.never         = b.localized(key: Noun.never.rawValue)
            self.delete        = Action.delete.localized(b)
            self.notFound      = Action.itemNotFound.localized(b)
            self.kind          = Action.reminderKind.localized(b)
            self.kindWater     = Action.reminderKindWater.localized(b)
            self.kindFertilize = Action.reminderKindFertilize.localized(b)
            self.kindTrim      = Action.reminderKindTrim.localized(b)
            self.kindMist      = Action.reminderKindMist.localized(b)
            self.kindMove      = Action.reminderKindMove.localized(b)
            self.kindOther     = Action.reminderKindOther.localized(b)
            self.interval      = Action.reminderInterval.localized(b)
            self.pause         = Action.pauseNotifications.localized(b)
            self.reminder      = Action.reminder.localized(b)
            self.notes         = Action.notes.localized(b)
            self.lastPerformed = Action.lastPerformed.localized(b)
        }
        
        public func interval(_ count: Int) -> ActionLocalization {
            .init(title: Formatter.reminderInterval.string(forDayInterval: count))
        }
        
        public func timeAgo(_ date: Date?) -> ActionLocalization {
            let formatted = date.map { Formatter.timeAgo.timeAgoString(for: $0) }
            return .init(title: formatted ?? self.never)
        }
    }
    
    @Localize private var bundle
    
    public init() {}
    
    public var wrappedValue: Value {
        Value(self.bundle)
    }
}
