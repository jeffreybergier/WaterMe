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

// Doesn't encode errors
// Errors should be saved via ErrorQueue serialization

extension NavigationGeneric: RawRepresentable {
    public init?(rawValue: String) { return nil }
    public var rawValue: String { "" }
}

extension NavigationReminderList: RawRepresentable {

    public init?(rawValue: String) {
        do {
            guard let data = Data(base64Encoded: rawValue) else { return nil }
            let d = try PropertyListDecoder().decode(NavigationReminderList.self, from: data)
            self.isSettings = d.isSettings
            self.isWatering = d.isWatering
            self.isSummary = d.isSummary
            self.isReminderEdit = d.isReminderEdit
            self.isVesselEdit = d.isVesselEdit
        } catch {
            assertionFailure("Failed to decode from SceneStorage")
            return nil
        }
    }

    public var rawValue: String {
        return (try? PropertyListEncoder().encode(self))?.base64EncodedString() ?? ""
    }
}

extension NavigationReminderEdit: RawRepresentable {
    public init?(rawValue: String) { return nil }
    public var rawValue: String { "" }
}

extension NavigationVesselEdit: RawRepresentable {

    public init?(rawValue: String) {
        do {
            guard let data = Data(base64Encoded: rawValue) else { return nil }
            let d = try PropertyListDecoder().decode(NavigationVesselEdit.self, from: data)
            self.isReminderEdit = d.isReminderEdit
            self.isIconMenu = d.isIconMenu
            self.isIconEmoji = d.isIconEmoji
            self.isIconCamera = d.isIconCamera
            self.isIconLibrary = d.isIconLibrary
            self.isIconView = d.isIconView
        } catch {
            assertionFailure("Failed to decode from SceneStorage")
            return nil
        }
    }

    public var rawValue: String {
        (try? PropertyListEncoder().encode(self))?.base64EncodedString() ?? ""
    }
}
