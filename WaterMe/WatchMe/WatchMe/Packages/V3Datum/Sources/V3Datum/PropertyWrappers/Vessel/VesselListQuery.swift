//
//  Created by Jeffrey Bergier on 2022/06/20.
//
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
import V3Model

@propertyWrapper
public struct VesselListQuery: DynamicProperty {

    // Basics
    @Controller private var controller
    @CDListQuery<CD_ReminderVessel, Vessel.Identifier, Error>(
        predicate: .init(value: false),
        onRead: { .init($0.objectID) }
    ) private var data
    @Environment(\.managedObjectContext) private var context
    @Environment(\.codableErrorResponder) private var errorResponder

    public init() { }

    private let needsUpdate = SecretBox(true)
    public func update() {
        guard self.needsUpdate.value else { return }
        self.needsUpdate.value = false
        _data.setOnError { error in
            NSLog(String(describing: error))
            self.errorResponder(.init(error))
        }
    }

    public var wrappedValue: some RandomAccessCollection<Vessel.Identifier> {
        self.data
    }
}
