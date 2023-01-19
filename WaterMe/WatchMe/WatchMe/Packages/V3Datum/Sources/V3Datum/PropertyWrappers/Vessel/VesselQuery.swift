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
    
    @Controller private var controller
    @ErrorStorage private var errors
    @CDObjectQuery<CD_ReminderVessel, Vessel>(onRead: Vessel.init(_:))
        private var object: Vessel?
    
    public init() { }
    
    public func setIdentifier(_ newValue: Vessel.Identifier?) {
        if
            let newValue,
            let url = URL(string: newValue.id)
        {
            _object.setObjectIDURL(url)
        } else {
            _object.setObjectIDURL(nil)
        }
    }
    
    public var wrappedValue: Vessel? {
        get { self.object }
        nonmutating set { self.object = newValue }
    }
    
    public var projectedValue: Binding<Vessel>? {
        self.$object
    }
    
    private let needsUpdate = SecretBox(true)
    public func update() {
        guard self.needsUpdate.value else { return }
        self.needsUpdate.value = false
        _object.setOnWrite(_controller.cd.cd_updateOpt(_:with:))
        _object.setOnError { error in
            NSLog(String(describing: error))
            self.errors.append(error)
        }
    }
}
