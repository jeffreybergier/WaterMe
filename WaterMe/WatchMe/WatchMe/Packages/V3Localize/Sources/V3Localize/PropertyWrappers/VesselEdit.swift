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
public struct VesselEdit: DynamicProperty {
    
    public struct Value {
        public var title:         LocalizedString
        public var delete:        ActionLocalization
        public var notFound:      ActionLocalization
        public var addReminder:   ActionLocalization
        public var reminders:     ActionLocalization
        public var name:          ActionLocalization
        public var photo:         ActionLocalization
        public var kindWater:     ActionLocalization
        public var kindFertilize: ActionLocalization
        public var kindTrim:      ActionLocalization
        public var kindMist:      ActionLocalization
        public var kindMove:      ActionLocalization
        public var kindOther:     ActionLocalization
        public var editPhoto:     ActionLocalization
        
        internal init(_ b: Bundle) {
            self.title         = b.localized(key: Noun.editPlant.rawValue)
            self.delete        = Action.delete.localized(b)
            self.notFound      = Action.itemNotFound.localized(b)
            self.addReminder   = Action.addReminder.localized(b)
            self.reminders     = Action.reminders.localized(b)
            self.name          = Action.name.localized(b)
            self.photo         = Action.photo.localized(b)
            self.kindWater     = Action.reminderKindWater.localized(b)
            self.kindFertilize = Action.reminderKindFertilize.localized(b)
            self.kindTrim      = Action.reminderKindTrim.localized(b)
            self.kindMist      = Action.reminderKindMist.localized(b)
            self.kindMove      = Action.reminderKindMove.localized(b)
            self.kindOther     = Action.reminderKindOther.localized(b)
            self.editPhoto     = Action.editPhoto.localized(b)
        }
        
        public func interval(_ count: Int) -> LocalizedString {
            Formatter.reminderInterval.string(forDayInterval: count)
        }
    }
    
    @Environment(\.bundle) private var bundle
    
    public init() {}
    
    public var wrappedValue: Value {
        Value(self.bundle)
    }
}
