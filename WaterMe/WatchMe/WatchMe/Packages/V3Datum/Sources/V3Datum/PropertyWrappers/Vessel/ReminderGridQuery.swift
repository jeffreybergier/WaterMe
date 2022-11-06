//
//  Created by Jeffrey Bergier on 2022/06/20.
//
//  Copyright © 2022 Saturday Apps.
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
import V3Model

@propertyWrapper
public struct ReminderGridQuery: DynamicProperty {
    
    public struct Section<C: RandomAccessCollection> {
        public var section: Reminder.Section
        public var data: C
    }
    
    @ReminderSectionQuery(.late)     private var late
    @ReminderSectionQuery(.today)    private var today
    @ReminderSectionQuery(.tomorrow) private var tomorrow
    @ReminderSectionQuery(.thisWeek) private var thisWeek
    @ReminderSectionQuery(.later)    private var later
    @ReminderSectionQuery(.disabled) private var disabled

    @Environment(\.codableErrorResponder) private var errorResponder
    
    public init() { }

    private let needsUpdate = SecretBox(true)
    public func update() {
        guard self.needsUpdate.value else { return }
        self.needsUpdate.value = false
        // TODO: Set Error Handlers on SectionQueries
    }

    public var wrappedValue: [Section<some RandomAccessCollection>] {
        [
            .init(section: .disabled, data: self.late),
            .init(section: .today,    data: self.today),
            .init(section: .tomorrow, data: self.tomorrow),
            .init(section: .thisWeek, data: self.thisWeek),
            .init(section: .later,    data: self.later),
            .init(section: .disabled, data: self.disabled),
        ]
    }
    
    // TODO: Create enum here  .none, .all, .reminder
    @State private var filter: Reminder.Filter = .none
    public func setFilter(_ newValue: Reminder.Filter) {
        // TODO: Hook this up
        self.filter = newValue
    }
}
