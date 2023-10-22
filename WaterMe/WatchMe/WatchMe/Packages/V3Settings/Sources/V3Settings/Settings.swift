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
import Umbrella

public var store = UserDefaults.standard

@propertyWrapper
public struct CheckForUpdatesOnLaunch: DynamicProperty {
    @AppStorage(
        UserDefaults.Constants.kCheckForUpdatesOnLaunch,
        store: store
    ) private var value = store.checkForUpdatesOnLaunch
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
public struct LastRequestedReviewDate: DynamicProperty {
    @JSBAppStorage(
        UserDefaults.Constants.kRequestReviewDate,
        store: store
    ) private var value: Date? = nil
    public init() {}
    public var wrappedValue: Date? {
        get { self.value }
        nonmutating set { self.value = newValue }
    }
    public var projectedValue: Binding<Date?> {
        self.$value
    }
}

@propertyWrapper
public struct LastBuildNumber: DynamicProperty {
    @AppStorage(
        UserDefaults.Constants.kBuildNumberKey,
        store: store
    ) private var value: Int?
    public init() {}
    public var wrappedValue: Int? {
        get { self.value }
        nonmutating set { self.value = newValue }
    }
    public var projectedValue: Binding<Int?> {
        self.$value
    }
}

@propertyWrapper
public struct IncreaseContrast: DynamicProperty {
    @Environment(\.colorSchemeContrast) private var contrast
    @AppStorage(
        UserDefaults.Constants.kIncreaseContrast,
        store: store
    )
    private var value = store.increaseContrast
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
public struct DarkModeProp: DynamicProperty {
    @AppStorage(
        UserDefaults.Constants.kDarkMode,
        store: store
    ) private var value = store.darkMode.rawValue
    public init() {}
    public var wrappedValue: DarkMode {
        get { .init(rawValue: self.value) ?? .system }
        nonmutating set { self.value = newValue.rawValue }
    }
    public var projectedValue: Binding<DarkMode> {
        Binding { self.wrappedValue } set: { self.wrappedValue = $0 }
    }
}

@propertyWrapper
public struct AskForNotifications: DynamicProperty {
    @AppStorage(
        UserDefaults.Constants.kFirstRun,
        store: store
    ) private var value = store.askForNotifications
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
public struct ControllerKindProp: DynamicProperty {
    @AppStorage(
        UserDefaults.Constants.kCloudSync,
        store: store
    ) private var value = store.controllerKind.rawValue
    public init() {}
    public var wrappedValue: ControllerKind {
        get { .init(rawValue: self.value) }
        nonmutating set { self.value = newValue.rawValue }
    }
    public var projectedValue: Binding<ControllerKind> {
        Binding {
            self.wrappedValue
        } set: {
            self.wrappedValue = $0
        }
    }
    public var raw: Binding<Bool> {
        Binding {
            self.wrappedValue.rawValue
        } set: {
            self.wrappedValue = .init(rawValue: $0)
        }
    }
}

@propertyWrapper
public struct CloudSyncInfoHasShown: DynamicProperty {
    @AppStorage(
        UserDefaults.Constants.kCloudSyncInfoShown,
        store: store
    ) private var value = store.hasCloudSyncInfoShown
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
    @AppStorage(
        UserDefaults.Constants.kDidRunWithoutCloudSync,
        store: store
    ) private var value = store.didRunWithoutCloudSync
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
public struct ReminderHourProp: DynamicProperty {
    @AppStorage(
        UserDefaults.Constants.kReminderHour,
        store: store
    ) private var value = store.reminderHour.rawValue
    public init() {}
    public var wrappedValue: ReminderHours {
        get { .init(rawValue: self.value) ?? .default }
        nonmutating set { self.value = newValue.rawValue }
    }
    public var projectedValue: Binding<ReminderHours> {
        Binding {
            self.wrappedValue
        } set: {
            self.wrappedValue = $0
        }
    }
}

@propertyWrapper
public struct ReminderDaysProp: DynamicProperty {
    @AppStorage(
        UserDefaults.Constants.kNumberOfReminderDays,
        store: store
    ) private var value = store.reminderDays.rawValue
    public init() {}
    public var wrappedValue: ReminderDays {
        get { .init(rawValue: self.value) ?? .default }
        nonmutating set { self.value = newValue.rawValue }
    }
    public var projectedValue: Binding<ReminderDays> {
        Binding {
            self.wrappedValue
        } set: {
            self.wrappedValue = $0
        }
    }
}
