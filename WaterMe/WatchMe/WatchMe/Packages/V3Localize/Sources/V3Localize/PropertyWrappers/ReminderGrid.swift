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
public struct ReminderGrid: DynamicProperty {
    
    public struct Value {
        public var title:                LocalizedString
        public var sectionTitleLate:     LocalizedString
        public var sectionTitleToday:    LocalizedString
        public var sectionTitleTomorrow: LocalizedString
        public var sectionTitleThisWeek: LocalizedString
        public var sectionTitleLater:    LocalizedString
        public var sectionTitleDisabled: LocalizedString
        public var kindWater:            LocalizedString
        public var kindFertilize:        LocalizedString
        public var kindMist:             LocalizedString
        public var kindTrim:             LocalizedString
        public var kindMove:             LocalizedString
        public var kindOther:            LocalizedString
        public var addPlant:             ActionLocalization
        public var noContent:            ActionLocalization
        
        internal init(_ b: LocalizeBundle) {
            self.title                = b.localized(key: Noun.appTitle.rawValue)
            self.sectionTitleLate     = b.localized(key: Noun.late.rawValue)
            self.sectionTitleToday    = b.localized(key: Noun.today.rawValue)
            self.sectionTitleTomorrow = b.localized(key: Noun.tomorrow.rawValue)
            self.sectionTitleThisWeek = b.localized(key: Noun.thisWeek.rawValue)
            self.sectionTitleLater    = b.localized(key: Noun.later.rawValue)
            self.sectionTitleDisabled = b.localized(key: Noun.paused.rawValue)
            self.kindWater            = b.localized(key: Noun.waterShort.rawValue)
            self.kindFertilize        = b.localized(key: Noun.fertilizeShort.rawValue)
            self.kindMist             = b.localized(key: Noun.mistShort.rawValue)
            self.kindTrim             = b.localized(key: Noun.trimShort.rawValue)
            self.kindMove             = b.localized(key: Noun.moveShort.rawValue)
            self.kindOther            = b.localized(key: Noun.other.rawValue)
            self.addPlant             = Action.addPlant.localized(b)
            self.noContent            = Action.noContent.localized(b)
        }
    }
    
    @Localize private var bundle
    
    public init() {}
    
    public var wrappedValue: Value {
        Value(self.bundle)
    }
}
