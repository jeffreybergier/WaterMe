//
//  Created by Jeffrey Bergier on 2023/05/28.
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
public struct QuickPerform: DynamicProperty {
    
    public struct Value {
        public var title:                    LocalizedString
        public var myPlant:                  LocalizedString
        public var sectionTitleTomorrow:     LocalizedString
        public var sectionTitleLateAndToday: LocalizedString
        public var kindWater:     ActionLocalization
        public var kindFertilize: ActionLocalization
        public var kindMist:      ActionLocalization
        public var kindTrim:      ActionLocalization
        public var kindMove:      ActionLocalization
        public var kindOther:     ActionLocalization
        public var itemNotFound:  ActionLocalization
        public var addPlant:      ActionLocalization
        private var bundle: Bundle
        public func menuTitle(_ count: Int) -> LocalizedString {
            switch count {
            case 0: ""
            default: NSAttributedString(
                AttributedString(
                    localized: Phrase.markXAsDoneMarkdown(count),
                    bundle: self.bundle
                )
            ).string
            }
        }

        internal init(_ b: Bundle) {
            self.title                    = b.localized(key: Noun.appTitle.rawValue)
            self.myPlant                  = b.localized(key: Noun.myPlant.rawValue)
            self.sectionTitleTomorrow     = b.localized(key: Noun.tomorrow.rawValue)
            self.sectionTitleLateAndToday = b.localized(key: Noun.late.rawValue)
            self.kindWater     = Action.reminderKindWater.localized(b)
            self.kindFertilize = Action.reminderKindFertilize.localized(b)
            self.kindMist      = Action.reminderKindMist.localized(b)
            self.kindTrim      = Action.reminderKindTrim.localized(b)
            self.kindMove      = Action.reminderKindMove.localized(b)
            self.kindOther     = Action.reminderKindOther.localized(b)
            self.itemNotFound  = Action.itemNotFound.localized(b)
            self.addPlant      = Action.addPlantLong.localized(b)
            self.bundle = b
        }
    }
    
    @Environment(\.bundle) private var bundle
    
    public init() {}
    
    public var wrappedValue: Value {
        Value(self.bundle)
    }
}
