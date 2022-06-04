//
//  Created by Jeffrey Bergier on 2022/06/03.
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

public var store = UserDefaults.standard

@propertyWrapper
public struct AskForNotifications: DynamicProperty {
    @AppStorage(UserDefaults.Constants.kFirstRun, store: store)
    private var value = true
    public init() {}
    public var wrappedValue: Bool {
        get { self.value }
        nonmutating set { self.value = newValue }
    }
    public var projectedValue: Binding<Bool> {
        self.$value
    }
}

@propertyWrapper
public struct CloudSync: DynamicProperty {
    @AppStorage(UserDefaults.Constants.kCloudSync, store: store)
    private var value = true
    public init() {}
    public var wrappedValue: ControllerKind {
        get { .init(rawValue: self.value) }
        nonmutating set { self.value = newValue.rawValue }
    }
    public var projectedValue: Binding<Bool> {
        Binding {
            self.wrappedValue.rawValue
        } set: {
            self.wrappedValue = .init(rawValue: $0)
        }
    }
}

@propertyWrapper
public struct CloudSyncInfoHasShown: DynamicProperty {
    @AppStorage(UserDefaults.Constants.kCloudSyncInfoShown, store: store)
    private var value = true
    public init() {}
    public var wrappedValue: Bool {
        get { self.value }
        nonmutating set { self.value = newValue }
    }
    public var projectedValue: Binding<Bool> {
        self.$value
    }
}

@propertyWrapper
public struct ReminderHour: DynamicProperty {
    @AppStorage(UserDefaults.Constants.kReminderHour, store: store)
    private var value = 8
    public init() {}
    public var wrappedValue: Hours {
        get { .init(rawValue: self.value) ?? .default }
        nonmutating set { self.value = newValue.rawValue }
    }
    public var projectedValue: Binding<Int> {
        self.$value
    }
}

@propertyWrapper
public struct ReminderDaysCount: DynamicProperty {
    @AppStorage(UserDefaults.Constants.kNumberOfReminderDays, store: store)
    private var value = 14
    public init() {}
    public var wrappedValue: Days {
        get { .init(rawValue: self.value) ?? .default }
        nonmutating set { self.value = newValue.rawValue }
    }
    public var projectedValue: Binding<Int> {
        self.$value
    }
}

@propertyWrapper
public struct IncreaseContrast: DynamicProperty {
    @Environment(\.colorSchemeContrast) private var contrast
    @AppStorage(UserDefaults.Constants.kIncreaseContrast, store: store)
    private var value = false
    public init() {}
    public var wrappedValue: Bool {
        get { self.contrast == .increased ? true : self.value }
        nonmutating set { self.value = newValue }
    }
    public var projectedValue: Binding<Bool> {
        Binding { self.wrappedValue } set: { self.wrappedValue = $0 }
    }
}

@propertyWrapper
public struct DarkMode: DynamicProperty {
    @AppStorage(UserDefaults.Constants.kDarkMode, store: store)
    private var value = 0
    public init() {}
    public var wrappedValue: DarkModeOverride {
        get { .init(rawValue: self.value) ?? .system }
        nonmutating set { self.value = newValue.rawValue }
    }
    public var projectedValue: Binding<DarkModeOverride> {
        Binding { self.wrappedValue } set: { self.wrappedValue = $0 }
    }
}

@propertyWrapper
public struct CheckForUpdatesOnLaunch: DynamicProperty {
    @AppStorage(UserDefaults.Constants.kCheckForUpdatesOnLaunch, store: store)
    private var value = true
    public init() {}
    public var wrappedValue: Bool {
        get { self.value }
        nonmutating set { self.value = newValue }
    }
    public var projectedValue: Binding<Bool> {
        self.$value
    }
}

@propertyWrapper
public struct DidRunWithoutCloudSync: DynamicProperty {
    @AppStorage(UserDefaults.Constants.kDidRunWithoutCloudSync, store: store)
    private var value = true
    public init() {}
    public var wrappedValue: Bool {
        get { self.value }
        nonmutating set { self.value = newValue }
    }
    public var projectedValue: Binding<Bool> {
        self.$value
    }
}
