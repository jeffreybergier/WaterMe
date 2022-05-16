//
//  Created by Jeffrey Bergier on 2021/12/31.
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
import Model

@propertyWrapper
public struct ReminderListQuery: DynamicProperty {

    @FetchRequest private var section0: FetchedResults<CD_Reminder>
    @FetchRequest private var section1: FetchedResults<CD_Reminder>
    @FetchRequest private var section2: FetchedResults<CD_Reminder>
    @FetchRequest private var section3: FetchedResults<CD_Reminder>
    @FetchRequest private var section4: FetchedResults<CD_Reminder>
    @FetchRequest private var section5: FetchedResults<CD_Reminder>

    public init() {
        _section0 = fetchRequest(for: .late)
        _section1 = fetchRequest(for: .today)
        _section2 = fetchRequest(for: .tomorrow)
        _section3 = fetchRequest(for: .thisWeek)
        _section4 = fetchRequest(for: .later)
        _section5 = fetchRequest(for: .disabled)
    }

    public var wrappedValue: [Reminder.Section] {
        return [
            .init(.late, TransformCollection(collection: self.section0) { Reminder(cd: $0) }
                    .eraseToAnyRandomAccessCollection()),
            .init(.today, TransformCollection(collection: self.section1) { Reminder(cd: $0) }
                    .eraseToAnyRandomAccessCollection()),
            .init(.tomorrow, TransformCollection(collection: self.section2) { Reminder(cd: $0) }
                    .eraseToAnyRandomAccessCollection()),
            .init(.thisWeek, TransformCollection(collection: self.section3) { Reminder(cd: $0) }
                    .eraseToAnyRandomAccessCollection()),
            .init(.later, TransformCollection(collection: self.section4) { Reminder(cd: $0) }
                    .eraseToAnyRandomAccessCollection()),
            .init(.disabled, TransformCollection(collection: self.section5) { Reminder(cd: $0) }
                    .eraseToAnyRandomAccessCollection())
        ]
    }
}

private func fetchRequest(for section: Reminder.Section.Kind) -> FetchRequest<CD_Reminder> {
    let enabledPredicate = NSPredicate(format: "%K == YES", #keyPath(CD_Reminder.raw_isEnabled))
    let disabledPredicate = NSPredicate(format: "%K == NO", #keyPath(CD_Reminder.raw_isEnabled))
    let normalPredicate: (DateInterval) -> NSPredicate = { range in
        return NSCompoundPredicate(andPredicateWithSubpredicates: [
            enabledPredicate,
            NSPredicate(format: "%K >= %@", #keyPath(CD_Reminder.raw_nextPerformDate), (range.start as NSDate)),
            NSPredicate(format: "%K < %@", #keyPath(CD_Reminder.raw_nextPerformDate), (range.end as NSDate))
        ])
    }

    let predicate: NSPredicate
    switch section {
    case .disabled:
        predicate = disabledPredicate
    case .later, .thisWeek, .today, .tomorrow:
        predicate = normalPredicate(section.dateInterval)
    case .late:
        let neverPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            enabledPredicate,
            NSPredicate(format: "%K == nil", #keyPath(CD_Reminder.raw_nextPerformDate))
        ])
        predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            normalPredicate(section.dateInterval),
            neverPredicate
        ])
    }
    let sd = [CD_Reminder.sortDescriptor(for: .nextPerformDate, ascending: true)]
    return FetchRequest(sortDescriptors: sd,
                        predicate: predicate,
                        animation: .default)
}
