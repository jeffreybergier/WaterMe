//
//  Created by Jeffrey Bergier on 2022/02/05.
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
import Errors

// Doesn't encode errors
// Errors should be saved via ErrorQueue serialization

extension NavigationGeneric: Codable {
    public func encode(to encoder: Encoder) throws { }
    public init(from decoder: Decoder) throws { }
}

extension NavigationReminderList: Codable {

    private enum CodingKeys: String, CodingKey {
         case settings, watering, summary, reminderEdit, vesselEdit
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(self.isSettings, forKey: .settings)
        try c.encode(self.isWatering, forKey: .watering)
        try c.encode(self.isSummary, forKey: .summary)
        try c.encode(self.isReminderEdit, forKey: .reminderEdit)
        try c.encode(self.isVesselEdit, forKey: .vesselEdit)
    }

    public init(from decoder: Decoder) throws {
        let d = try decoder.container(keyedBy: CodingKeys.self)
        self.isSettings     = (try?  d.decode(Bool.self, forKey: .settings)) ?? false
        self.isWatering     = try? d.decode(WateringInput.self, forKey: .watering)
        self.isSummary      = try? d.decode(ReminderAndVesselInput.self, forKey: .summary)
        self.isReminderEdit = try? d.decode(ReminderInput.self, forKey: .reminderEdit)
        self.isVesselEdit   = try? d.decode(VesselInput.self, forKey: .vesselEdit)
    }
}

extension NavigationReminderEdit: Codable {
    public func encode(to encoder: Encoder) throws { }
    public init(from decoder: Decoder) throws { }
}

extension NavigationVesselEdit: Codable {

    private enum CodingKeys: String, CodingKey {
         case reminderEdit, iconMenu, iconEmoji, iconCamera, iconLibrary, iconView
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(self.isReminderEdit, forKey: .reminderEdit)
        try c.encode(self.isIconMenu, forKey: .iconMenu)
        try c.encode(self.isIconEmoji, forKey: .iconEmoji)
        try c.encode(self.isIconCamera, forKey: .iconCamera)
        try c.encode(self.isIconLibrary, forKey: .iconLibrary)
        try c.encode(self.isIconView, forKey: .iconView)
    }

    public init(from decoder: Decoder) throws {
        let d = try decoder.container(keyedBy: CodingKeys.self)
        self.isReminderEdit = try? d.decode(ReminderInput.self, forKey: .reminderEdit)
        self.isIconMenu     = try? d.decode(VesselInput.self, forKey: .iconMenu)
        self.isIconEmoji    = try? d.decode(VesselInput.self, forKey: .iconEmoji)
        self.isIconCamera   = try? d.decode(VesselInput.self, forKey: .iconCamera)
        self.isIconLibrary  = try? d.decode(VesselInput.self, forKey: .iconLibrary)
        self.isIconView     = try? d.decode(VesselInput.self, forKey: .iconView)
    }
}
