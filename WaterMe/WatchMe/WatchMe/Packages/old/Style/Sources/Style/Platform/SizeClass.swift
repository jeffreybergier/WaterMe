//
//  Created by Jeffrey Bergier on 2022/02/06.
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

public enum Size: CaseIterable {
    case small, medium, large
}

@propertyWrapper
public struct SizeClass: DynamicProperty {

    public struct Value {
        public var horizontal: Size
        public var vertical: Size
    }

    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var system_hClass
    @Environment(\.verticalSizeClass) private var system_vClass
    #endif

    public init() {}

    public var wrappedValue: Value {
        #if os(iOS)
        return .init(horizontal: .init(self.system_hClass),
                     vertical: .init(self.system_vClass))
        #else
        return .init(horizontal: .init(),
                     vertical: .init())
        #endif
    }
}

extension Size {
    #if os(iOS)
    internal init(_ system: UserInterfaceSizeClass?) {
        switch system {
        case .compact: self = .medium
        case .regular: self = .large
        case .none: fallthrough
        @unknown default: self = .medium
        }
    }
    #else
    internal init() {
        #if os(watchOS)
        self = .small
        #else
        self = .large
        #endif
    }
    #endif
}
