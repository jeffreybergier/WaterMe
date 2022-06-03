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

import Umbrella

/// This type is never used but it helps make sure all the navigations have the same capabilities
public protocol NavigationProtocol: Codable, RawRepresentable {
    var isError: UserFacingError? { get set }
    @discardableResult mutating func append(_ error: UserFacingError) -> UserFacingError?
}

public struct NavigationGeneric: NavigationProtocol {
    public var isError: UserFacingError?
    @discardableResult public mutating func append(_ error: UserFacingError) -> UserFacingError? {
        if self.isError != nil { return error }
        self.isError = error
        return nil
    }
}

public struct NavigationReminderList: NavigationProtocol {
    public var isError: UserFacingError?
    public var isSettings: Bool = false
    public var isWatering: WateringInput?
    public var isSummary: ReminderAndVesselInput?
    public var isReminderEdit: ReminderInput?
    public var isVesselEdit: VesselInput?
    @discardableResult public mutating func append(_ error: UserFacingError) -> UserFacingError? {
        if self.isError != nil { return error }
        if self.isSettings == true { return error }
        if self.isWatering != nil { return error }
        if self.isSummary != nil { return error }
        if self.isReminderEdit != nil { return error }
        if self.isVesselEdit != nil { return error }
        self.isError = error
        return nil
    }
}

public struct NavigationReminderEdit: NavigationProtocol {
    public var isError: UserFacingError?
    @discardableResult public mutating func append(_ error: UserFacingError) -> UserFacingError? {
        if self.isError != nil { return error }
        self.isError = error
        return nil
    }
}

public struct NavigationVesselEdit: NavigationProtocol {
    public var isError: UserFacingError?
    public var isReminderEdit: ReminderInput?
    public var isIconMenu: VesselInput?
    public var isIconEmoji: VesselInput?
    public var isIconCamera: VesselInput?
    public var isIconLibrary: VesselInput?
    public var isIconView: VesselInput?
    @discardableResult public mutating func append(_ error: UserFacingError) -> UserFacingError? {
        if self.isError != nil { return error }
        if self.isReminderEdit != nil { return error }
        if self.isIconMenu != nil { return error }
        if self.isIconEmoji != nil { return error }
        if self.isIconCamera != nil { return error }
        if self.isIconLibrary != nil { return error }
        if self.isIconView != nil { return error }
        self.isError = error
        return nil
    }
}
