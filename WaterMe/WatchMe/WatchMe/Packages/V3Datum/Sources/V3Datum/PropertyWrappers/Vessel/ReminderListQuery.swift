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
internal struct ReminderListQuery: DynamicProperty {

    @Controller private var controller
    @CDListQuery<CD_Reminder, Reminder.Identifier, Error>(
        predicate: .init(value: false),
        onRead: { .init($0.objectID) }
    ) private var data
    @Environment(\.codableErrorResponder) private var errorResponder
    
    @State private var filter: Reminder.Filter = .none
    public let section: Reminder.Section?
    
    internal init(_ section: Reminder.Section? = nil) {
        self.section = section
    }

    private let needsUpdate = SecretBox(true)
    internal func update() {
        guard self.needsUpdate.value else { return }
        self.needsUpdate.value = false
        _data.setOnError { error in
            NSLog(String(describing: error))
            self.errorResponder(.init(error))
        }
        self.updateCoreData()
    }

    internal var wrappedValue: some RandomAccessCollection<Reminder.Identifier> {
        self.data
    }
    
    internal func setFilter(_ newValue: Reminder.Filter) {
        self.filter = newValue
        self.updateCoreData()
    }
    private func updateCoreData() {
        // 0) Make sure we always complete our mission
        var predicate = NSPredicate(value: false)
        defer { _data.setPredicate(predicate) }
        
        // 1) If filter is none, nothing should load ever
        if case .none = self.filter { return }
        
        // 2) Try to obtain the other two predicates
        let section = self.section?.cd_predicate ?? .init(value: true)
        let filterResult = self.filter.cd_predicate(_controller.cd.cd_search)
        
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
