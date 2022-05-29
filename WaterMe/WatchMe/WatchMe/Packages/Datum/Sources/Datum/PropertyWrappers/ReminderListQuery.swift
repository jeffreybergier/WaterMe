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
import Umbrella
import Model

@propertyWrapper
public struct ReminderListQuery: DynamicProperty {

    @CDListQuery<CD_Reminder, Reminder, Error> private var section0: AnyRandomAccessCollection<Reminder>
    @CDListQuery<CD_Reminder, Reminder, Error> private var section1: AnyRandomAccessCollection<Reminder>
    @CDListQuery<CD_Reminder, Reminder, Error> private var section2: AnyRandomAccessCollection<Reminder>
    @CDListQuery<CD_Reminder, Reminder, Error> private var section3: AnyRandomAccessCollection<Reminder>
    @CDListQuery<CD_Reminder, Reminder, Error> private var section4: AnyRandomAccessCollection<Reminder>
    @CDListQuery<CD_Reminder, Reminder, Error> private var section5: AnyRandomAccessCollection<Reminder>

    @ControllerProperty private var controller

    public init() {
        _section0 = query(for: .late)
        _section1 = query(for: .today)
        _section2 = query(for: .tomorrow)
        _section3 = query(for: .thisWeek)
        _section4 = query(for: .later)
        _section5 = query(for: .disabled)
    }

    public mutating func update() {
        guard _section0.onWrite.value == nil else { return }
        _section0.onWrite.value = _controller.cdController.update(_:with:)
        _section1.onWrite.value = _controller.cdController.update(_:with:)
        _section2.onWrite.value = _controller.cdController.update(_:with:)
        _section3.onWrite.value = _controller.cdController.update(_:with:)
        _section4.onWrite.value = _controller.cdController.update(_:with:)
        _section5.onWrite.value = _controller.cdController.update(_:with:)
    }

    public var wrappedValue: [Reminder.Section] {
        return [
            .init(self.section0, .late),
            .init(self.section1, .today),
            .init(self.section2, .tomorrow),
            .init(self.section3, .thisWeek),
            .init(self.section4, .later),
            .init(self.section5, .disabled),
        ]
    }

    public var projectedValue: [Reminder.BindingSection] {
        return [
            .init(self.$section0, .late),
            .init(self.$section1, .today),
            .init(self.$section2, .tomorrow),
            .init(self.$section3, .thisWeek),
            .init(self.$section4, .later),
            .init(self.$section5, .disabled),
        ]
    }
}

private func query(for section: Reminder.Section.Kind) -> CDListQuery<CD_Reminder, Reminder, Error> {
    let enabledPredicate = NSPredicate(format: "%K == YES", #keyPath(CD_Reminder.raw_isEnabled))
    let disabledPredicate = NSPredicate(format: "%K == NO", #keyPath(CD_Reminder.raw_isEnabled))
    let normalPredicate: (DateInterval) -> NSPredicate = { range in
        return NSCompoundPredicate(andPredicateWithSubpredicates: [
            enabledPredicate,
            NSPredicate(format: "%K >= %@", #keyPath(CD_Reminder.raw_nextPerformDate), (range.start as NSDate)),
            NSPredicate(format: "%K < %@", #keyPath(CD_Reminder.raw_nextPerformDate), (range.end as NSDate)),
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
            NSPredicate(format: "%K == nil", #keyPath(CD_Reminder.raw_nextPerformDate)),
        ])
        predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            normalPredicate(section.dateInterval),
            neverPredicate,
        ])
    }
    let sort = [CD_Reminder.sortDescriptor(for: .nextPerformDate, ascending: true)]
    return CDListQuery(sort: sort,
                       predicate: predicate,
                       animation: .default)
    {
        Reminder(cd: $0)
    }
}
