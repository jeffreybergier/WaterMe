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
    
    public struct Sections<C1, C2, C3, C4, C5, C6> {
        public var section1: Reminder.Section
        public var section1Data: C1
        public var section2: Reminder.Section
        public var section2Data: C2
        public var section3: Reminder.Section
        public var section3Data: C3
        public var section4: Reminder.Section
        public var section4Data: C4
        public var section5: Reminder.Section
        public var section5Data: C5
        public var section6: Reminder.Section
        public var section6Data: C6
    }
    
    @ReminderSectionQuery(.late)     private var late
    @ReminderSectionQuery(.today)    private var today
    @ReminderSectionQuery(.tomorrow) private var tomorrow
    @ReminderSectionQuery(.thisWeek) private var thisWeek
    @ReminderSectionQuery(.later)    private var later
    @ReminderSectionQuery(.disabled) private var disabled

    @Environment(\.codableErrorResponder) private var errorResponder
    
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

    public var wrappedValue: Sections<some RandomAccessCollection<Reminder.Identifier>,
                                      some RandomAccessCollection<Reminder.Identifier>,
                                      some RandomAccessCollection<Reminder.Identifier>,
                                      some RandomAccessCollection<Reminder.Identifier>,
                                      some RandomAccessCollection<Reminder.Identifier>,
                                      some RandomAccessCollection<Reminder.Identifier>>
    {
        .init(
            section1: .disabled, section1Data: self.late,
            section2: .today,    section2Data: self.today,
            section3: .tomorrow, section3Data: self.tomorrow,
            section4: .thisWeek, section4Data: self.thisWeek,
            section5: .later,    section5Data: self.later,
            section6: .disabled, section6Data: self.disabled
        )
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
