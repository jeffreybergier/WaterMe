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
        public var title:       LocalizedString
        public var delete:      ActionLocalization
        public var notFound:    ActionLocalization
        public var addReminder: ActionLocalization
        public var reminders:   ActionLocalization
        public var name:        ActionLocalization
        public var photo:       ActionLocalization
        
        internal init(_ b: LocalizeBundle) {
            self.title       = b.localized(key: Noun.editPlant.rawValue)
            self.delete      = Action.delete.localized(b)
            self.notFound    = Action.itemNotFound.localized(b)
            self.addReminder = Action.addReminder.localized(b)
            self.reminders   = Action.reminders.localized(b)
            self.name        = Action.name.localized(b)
            self.photo       = Action.photo.localized(b)
        }
    }
    
    @Localize private var bundle
    
    public init() {}
    
    public var wrappedValue: Value {
        Value(self.bundle)
    }
}
