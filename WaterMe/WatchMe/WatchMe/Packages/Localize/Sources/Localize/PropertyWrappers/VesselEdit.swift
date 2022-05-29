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

@propertyWrapper
public struct VesselEdit: DynamicProperty {

    public struct Value {
        public var title: LocalizationKey = Label.editPlant
        public var buttonDone: LocalizationKey = Action.done
        public var buttonDelete: LocalizationKey = Action.delete
        public var buttonAddReminder: LocalizationKey = Action.addReminder
        public var sectionPhoto: LocalizationKey = Label.photo
        public var sectionName: LocalizationKey = Label.name
        public var sectionReminders: LocalizationKey = Label.reminders
        public var placeholderPlantName: LocalizationKey = Label.plantName
        public var subsectionEvery: LocalizationKey = Label.everyColon
    }

    private static let reminderIntervalFormatter = Formatter.newReminderIntervalFormatter

    @EnvironmentBundle<LocalizeBundle> private var bundle

    public init() {}

    public var wrappedValue: (KeyPath<Value, LocalizationKey>) -> LocalizedString {{
        self.bundle.localized(key: Value()[keyPath: $0])
    }}

    // TODO: Find workaround for this
    // It would be nice if I could somehow do this via `Value`
    public func subsectionDataDayInterval(_ interval: Int) -> LocalizedString {
        VesselEdit.reminderIntervalFormatter.string(forDayInterval: interval)
    }
    public func subsectionDataKind(_ kind: ReminderKind) -> LocalizedString {
        self.bundle.localized(key: kind.localizedLong)
    }
}
