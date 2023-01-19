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
    
    public struct Value<C1, C2, C3, C4, C5, C6> {
        public var late: C1
        public var today: C2
        public var tomorrow: C3
        public var thisWeek: C4
        public var later: C5
        public var disabled: C6
        
        internal init(late: C1,
                      today: C2,
                      tomorrow: C3,
                      thisWeek: C4,
                      later: C5,
                      disabled: C6)
        {
            self.late = late
            self.today = today
            self.tomorrow = tomorrow
            self.thisWeek = thisWeek
            self.later = later
            self.disabled = disabled
        }
    }
    
    @ReminderListQuery(.late)     private var late
    @ReminderListQuery(.today)    private var today
    @ReminderListQuery(.tomorrow) private var tomorrow
    @ReminderListQuery(.thisWeek) private var thisWeek
    @ReminderListQuery(.later)    private var later
    @ReminderListQuery(.disabled) private var disabled
    
    @State private var filter: Reminder.Filter = .none
    
    public init() { }

    private let needsUpdate = SecretBox(true)
    public func update() {
        guard self.needsUpdate.value else { return }
        self.needsUpdate.value = false
        self.updateCoreData()
    }
    
    /*
     // TODO: Do it like this when the compiler allows
     public struct Section<C: RandomAccessCollection>: Identifiable {
         public var section: Reminder.Section
         public var data: C
         public var id: Int { self.section.id }
     }
     public var wrappedValue: [Section<some RandomAccessCollection<Reminder.Identifier>>] {
     */

    public var wrappedValue: Value<some RandomAccessCollection<Reminder.Identifier>,
                                   some RandomAccessCollection<Reminder.Identifier>,
                                   some RandomAccessCollection<Reminder.Identifier>,
                                   some RandomAccessCollection<Reminder.Identifier>,
                                   some RandomAccessCollection<Reminder.Identifier>,
                                   some RandomAccessCollection<Reminder.Identifier>>
    {
        .init(late:     self.late,
              today:    self.today,
              tomorrow: self.tomorrow,
              thisWeek: self.thisWeek,
              later:    self.later,
              disabled: self.disabled)
    }
    
    public func setFilter(_ newValue: Reminder.Filter) {
        self.filter = newValue
        self.updateCoreData()
    }
    
    private func updateCoreData() {
        _late.setFilter(self.filter)
        _today.setFilter(self.filter)
        _tomorrow.setFilter(self.filter)
        _thisWeek.setFilter(self.filter)
        _later.setFilter(self.filter)
        _disabled.setFilter(self.filter)
    }
}
