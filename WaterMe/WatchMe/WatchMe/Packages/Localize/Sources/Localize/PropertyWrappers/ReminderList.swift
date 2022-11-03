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
import Umbrella
import Model

@propertyWrapper
public struct ReminderList: DynamicProperty {

    public struct Value {
        public var title: LocalizationKey = Label.appTitle
        public var buttonAdd: LocalizationKey = Action.addPlant
        public var buttonSettings: LocalizationKey = Action.settings
        public var subsectionPlaceholderName: LocalizationKey = Label.myPlant
    }

    @EnvironmentBundle<LocalizeBundle> private var bundle

    public init() {}

    public var wrappedValue: (KeyPath<Value, LocalizationKey>) -> LocalizedString {{
        self.bundle.localized(key: Value()[keyPath: $0])
    }}

    // TODO: Find workaround for this
    // It would be nice if I could somehow do this via `Value`
    public func sectionHeader(_ kind: Reminder.Section.Kind) -> LocalizedString {
        self.bundle.localized(key: kind.localized)
    }
    public func subsectionDataKind(_ kind: ReminderKind) -> LocalizedString {
        self.bundle.localized(key: kind.localizedShort)
    }
}
