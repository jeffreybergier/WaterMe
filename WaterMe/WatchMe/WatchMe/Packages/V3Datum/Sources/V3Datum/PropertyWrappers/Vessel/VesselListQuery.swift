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
public struct VesselListQuery: DynamicProperty {
    
    public struct Value<C> {
        public let data: C
        public var filter: Vessel.Filter
    }

    @State private var filter: Vessel.Filter = .none
    @CDListQuery<CD_ReminderVessel, Vessel.Identifier>(onRead: { .init($0.objectID) }) private var query
    
    public init() { }

    public var wrappedValue: Value<some RandomAccessCollection<Vessel.Identifier>> {
        get { .init(data: self.query.data, filter: self.filter) }
        nonmutating set { self.setFilter(newValue.filter) }
    }
    
    private func setFilter(_ newValue: Vessel.Filter) {
        let oldFilter = self.filter
        self.filter = newValue
        guard oldFilter != newValue else { return }
        
        self.query.configuration.predicate = self.filter.cd_predicate
    }
}
