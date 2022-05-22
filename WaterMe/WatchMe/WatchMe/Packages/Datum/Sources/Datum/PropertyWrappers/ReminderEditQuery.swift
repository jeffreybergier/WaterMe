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
import CoreData
import Model
import Umbrella

@propertyWrapper
public struct ReminderEditQuery: DynamicProperty {
    
    @CDObjectQuery<CD_Reminder, Reminder, Error> private var reminder: Reminder?
    @ControllerProperty private var controller

    public init(id: Reminder.アイディ) {
        let url = URL(string: id.id)!
        _reminder = .init(objectIDURL: url) {
            Reminder(cd: $0)
        }
    }
    
    public mutating func update() {
        guard self._reminder.onWrite.value == nil else { return }
        self._reminder.onWrite.value = self._controller.cdController.updateOpt(_:with:)
    }
    
    public var wrappedValue: Reminder {
        get { self.reminder! }
        nonmutating set { self.reminder = newValue }
    }
    
    public var projectedValue: Binding<Reminder> {
        self.$reminder!
    }
}
