//
//  Created by Jeffrey Bergier on 2022/01/28.
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

@propertyWrapper
public struct NavGeneric: DynamicProperty {
    @SceneStorage("NavigationGeneric") private var store = NavigationGeneric()
    public init() {}
    public var wrappedValue: NavigationGeneric {
        get { self.store }
        nonmutating set { self.store = newValue }
    }
    public var projectedValue: Binding<NavigationGeneric> {
        Binding { self.wrappedValue }
        set: { self.store = $0 }
    }
}

@propertyWrapper
public struct NavReminderList: DynamicProperty {
    @SceneStorage("NavigationReminderList") private var store = NavigationReminderList()
    public init() {}
    public var wrappedValue: NavigationReminderList {
        get { self.store }
        nonmutating set { self.store = newValue }
    }
    public var projectedValue: Binding<NavigationReminderList> {
        Binding { self.wrappedValue }
        set: { self.store = $0 }
    }
}

@propertyWrapper
public struct NavReminderEdit: DynamicProperty {
    @SceneStorage("NavigationReminderEdit") private var store = NavigationReminderEdit()
    public init() {}
    public var wrappedValue: NavigationReminderEdit {
        get { self.store }
        nonmutating set { self.store = newValue }
    }
    public var projectedValue: Binding<NavigationReminderEdit> {
        Binding { self.wrappedValue }
        set: { self.store = $0 }
    }
}

@propertyWrapper
public struct NavVesselEdit: DynamicProperty {
    @SceneStorage("NavigationVesselEdit") private var store = NavigationVesselEdit()
    public init() {}
    public var wrappedValue: NavigationVesselEdit {
        get { self.store }
        nonmutating set { self.store = newValue }
    }
    public var projectedValue: Binding<NavigationVesselEdit> {
        Binding { self.wrappedValue }
        set: { self.store = $0 }
    }
}
