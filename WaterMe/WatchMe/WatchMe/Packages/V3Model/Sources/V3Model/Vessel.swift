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

import Foundation

public struct Vessel: Identifiable, Hashable, Equatable {

    public typealias Selection = Set<Vessel.Identifier>

    public struct Identifier: Hashable, Equatable, Codable, RawRepresentable, Identifiable {
        public var id: String { self.rawValue }
        public var rawValue: String
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    public var id: Identifier
    public var displayName: String?
    public var icon: VesselIcon?
    public var kind: VesselKind
    public var isDeleted: Bool
//  public var isModelComplete: ModelCompleteError?
    public var shortLabelSafeDisplayName: String? {
        self.displayName?.truncated(to: 20)
    }

    public init(id: Identifier,
                displayName: String? = nil,
                icon: VesselIcon? = nil,
                kind: VesselKind? = nil,
                isDeleted: Bool = false)
    {
        self.id = id
        self.displayName = displayName
        self.icon = icon
        self.kind = kind ?? .plant
        self.isDeleted = isDeleted
    }
}
