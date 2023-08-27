//
//  Created by Jeffrey Bergier on 2023/08/27.
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
public struct QuickPerformQuery: DynamicProperty {
    
    public struct Value<C1> {
        public let data: C1
        public var filter: Reminder.Filter = .none
    }
    
    @ReminderListQuery private var query
    
    @State private var filter: Reminder.Filter = .none
    
    public init(_ section: Reminder.Section) {
        _query = .init(section)
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

    public var wrappedValue: Value<some RandomAccessCollection<Reminder.Identifier>>
    {
        nonmutating set { self.setFilter(newValue.filter) }
        get {
            .init(data: self.query.data, filter: self.filter)
        }
    }
    
    private func setFilter(_ newValue: Reminder.Filter) {
        let oldFilter = self.filter
        self.filter = newValue
        guard oldFilter != newValue else { return }
        
        self.query.filter     = self.filter
    }
}
