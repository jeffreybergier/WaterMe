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
        public let section: Reminder.Section?
        public var filter: Reminder.Filter
    }

    @Controller private var controller
    @State private var filter: Reminder.Filter = .none
    @CDListQuery<CD_Reminder, Reminder.Identifier>(onRead: { .init($0.objectID) }) private var query
    
    public let section: Reminder.Section?
    
    public init(_ section: Reminder.Section? = nil) {
        self.section = section
    }

    public var wrappedValue: Value<some RandomAccessCollection<Reminder.Identifier>> {
        get { .init(data: self.query.data, section: self.section, filter: self.filter) }
        nonmutating set { self.setFilter(newValue.filter) }
    }
    
    private func setFilter(_ newValue: Reminder.Filter) {
        let oldFilter = self.filter
        self.filter = newValue
        guard oldFilter != newValue else { return }
        self.updateCoreData()
    }
    
    private func updateCoreData() {
        // 0) Make sure we always complete our mission
        var predicate = NSPredicate(value: false)
        defer { self.query.configuration.predicate = predicate }
        
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
            // 4) Present error to UI
            // TODO: Do something with this error
            NSLog(String(describing: error))
        }
    }
}
