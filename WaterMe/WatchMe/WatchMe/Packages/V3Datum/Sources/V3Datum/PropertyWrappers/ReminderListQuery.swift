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
public struct ReminderListQuery: DynamicProperty {
    
    public struct Value<C> {
        public let data: C
        public var section: Reminder.Section?
        public var filter: Reminder.Filter
    }

    @ErrorStorage private var errors
    @Controller private var controller
    @CDListQuery<CD_Reminder, Reminder.Identifier>(onRead: { .init($0.objectID) }) private var query
    
    @StateObject private var timeChange: SecretBox<Int> = .init(-1)
    @StateObject private var timeChangeTrigger = NotificationCenter.default.observable(
        // Stringly typed to avoid importing UIKit
        .init(rawValue: "UIApplicationSignificantTimeChangeNotification")
    )
    
    @State private var section: Reminder.Section?
    @State private var filter: Reminder.Filter
    
    public init(_ section: Reminder.Section? = nil, filter: Reminder.Filter = .none) {
        _section = .init(initialValue: section)
        _filter = .init(initialValue: filter)
    }

    public var wrappedValue: Value<some RandomAccessCollection<Reminder.Identifier>> {
        nonmutating set { self.setQuery(newFilter: newValue.filter, newSection: newValue.section) }
        get {
            // Detect if significant time has changed. If so, update core data
            if self.timeChange.value != self.timeChangeTrigger.randomNumber {
                self.updateCoreData()
            }
            return .init(data: self.query.data, 
                         section: self.section,
                         filter: self.filter)
        }
    }
    
    private func setQuery(newFilter: Reminder.Filter, newSection: Reminder.Section?) {
        let oldFilter = self.filter
        let oldSection = self.section
        guard oldFilter != newFilter || oldSection != newSection else { return }
        self.filter = newFilter
        self.section = newSection
        self.updateCoreData()
    }
    
    private func updateCoreData() {
        // 0) Make sure we always complete our mission
        var predicate = NSPredicate(value: false)
        defer {
            // Capture a value so we can tell if the time changed since the last request
            self.timeChange.value = self.timeChangeTrigger.randomNumber
            self.query.configuration.predicate = predicate
            // TODO: This needs more testing
            // Its very hard to tell what order this is with fake data
            self.query.configuration.sortDescriptors = [
                .init(\.raw_nextPerformDate, order: .forward),
            ]
        }
        
        // 1) If filter is none, nothing should load ever
        if case .none = self.filter { return }
        
        // 2) Try to obtain the other two predicates
        let section = self.section?.cd_predicate ?? .init(value: true)
        let filterResult = self.filter.cd_predicate(
            share:  _controller.cd.cd_search,
            vessel: _controller.cd.cd_search
        )
        
        switch filterResult {
        case .success(let filter):
            // 3) AND the other two predicates for the complete search
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                section,
                filter,
            ])
        case .failure(let error):
            self.errors.append(error)
        }
    }
}
