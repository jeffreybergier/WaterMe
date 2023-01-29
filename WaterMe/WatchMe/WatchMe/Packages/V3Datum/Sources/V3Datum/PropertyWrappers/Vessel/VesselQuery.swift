//
//  Created by Jeffrey Bergier on 2022/11/06.
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
public struct VesselQuery: DynamicProperty {
    
    public struct Value {
        public let data: Vessel?
        public var identifier: Vessel.Identifier?
    }
    
    @ErrorStorage private var errors
    @Controller private var controller
    @State private var identifier: Vessel.Identifier?
    @CDObjectQuery<CD_ReminderVessel, Vessel>(onRead: Vessel.init(_:)) private var query
    
    public init() { }
    
    public var wrappedValue: Value {
        nonmutating set { self.write(newValue.identifier) }
        get { .init(data: self.query.data, identifier: self.identifier) }
    }
    
    public var projectedValue: Binding<Vessel>? {
        self.$query
    }
    
    private func write(_ newValue: Vessel.Identifier?) {
        let oldIdentifier = self.identifier
        self.identifier = newValue
        guard oldIdentifier != newValue else { return }
        
        var configuration = self.query.configuration
        if configuration.onWrite == nil {
            configuration.onWrite = _controller.cd.cd_update(_:with:)
        }
        if configuration.onError == nil {
            configuration.onError = self.errors.append(_:)
        }
        if let newID = newValue {
            configuration.objectID = URL(string: newID.id)
        } else {
            configuration.objectID = nil
        }
        self.query.configuration = configuration
    }
}
