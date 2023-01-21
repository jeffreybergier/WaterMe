//
//  Created by Jeffrey Bergier on 2022/11/11.
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
public struct ReminderQuery: DynamicProperty {
    
    public struct Value {
        public var data: Reminder?
        public var id: Reminder.Identifier?
    }
    
    @ErrorStorage private var errors
    @Controller private var controller
    @CDObjectQuery<CD_Reminder, Reminder>(onRead: Reminder.init(_:)) private var query
    @StateObject private var identifier: SecretBox<Reminder.Identifier?> = .init(nil)
    
    public init() { }
    
    public var wrappedValue: Value {
        nonmutating set { self.write(newValue) }
        get {
            .init(data: self.query.data,
                  id: self.identifier.value)
        }
    }
    
    public var projectedValue: Binding<Reminder>? {
        self.$query
    }
    
    private func write(_ newValue: Value) {
        var outputValue = self.query
        if outputValue.onWrite == nil {
            outputValue.onWrite = _controller.cd.cd_update(_:with:)
        }
        if outputValue.onError == nil {
            outputValue.onError = self.errors.append(_:)
        }
        if let newID = newValue.id {
            outputValue.id = URL(string: newID.id)
        } else {
            outputValue.id = nil
        }
        outputValue.data = newValue.data
        self.query = outputValue
    }
}
