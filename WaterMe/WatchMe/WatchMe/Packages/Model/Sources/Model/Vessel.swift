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

public struct Vessel: Hashable, Identifiable {
    public var id: アイディ
    public var displayName: String?
    public var icon: VesselIcon?
    public var kind: VesselKind
//  public var isModelComplete: ModelCompleteError?
    public var shortLabelSafeDisplayName: String? {
        self.displayName?.truncated(to: 20)
    }

    public init(id: アイディ,
                displayName: String? = nil,
                icon: VesselIcon? = nil,
                kind: VesselKind = .plant)
    {
        self.id = id
        self.displayName = displayName
        self.icon = icon
        self.kind = kind
    }
}

extension Vessel {
    public struct アイディ: Codable, Identifiable, Hashable {
        public var id: String
        public init(_ id: String) {
            self.id = id
        }
    }
}
