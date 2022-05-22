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
public struct VesselEditReminderQuery: DynamicProperty {
    
    @CDListQuery<CD_Reminder, Reminder, Error> private var data: AnyRandomAccessCollection<Reminder>
    @CDObjectQuery<CD_ReminderVessel, Vessel, Error> private var vessel: Vessel?
    @ControllerProperty private var controller
    
    public init(id: Vessel.アイディ) {
        let url = URL(string: id.id)!
        _vessel = .init(objectIDURL: url) { Vessel(cd:$0) }
        _data = .init(predicate: NSPredicate(value: false),
                      animation: .default)
        { cd in
            Reminder(cd: cd)
        }
    }
    
    public mutating func update() {
        guard
            self._data.onWrite.value == nil,
            let id = self._vessel.object.value?.objectID
        else { return }
        
        // enable saving changes
        self._data.onWrite.value = self._controller.cdController.update(_:with:)
        
        // update the query
        let sort = NSSortDescriptor(keyPath: \CD_Reminder.raw_dateCreated, ascending: true)
        let pred = NSPredicate(format: "%K == %@", #keyPath(CD_Reminder.raw_vessel), id)
        self._data.request.nsSortDescriptors = [sort]
        self._data.request.nsPredicate = pred
    }
    
    public var wrappedValue: AnyRandomAccessCollection<Reminder> {
        self.data
    }
    
    public var projectedValue: AnyRandomAccessCollection<Binding<Reminder>> {
        self.$data
    }
}
