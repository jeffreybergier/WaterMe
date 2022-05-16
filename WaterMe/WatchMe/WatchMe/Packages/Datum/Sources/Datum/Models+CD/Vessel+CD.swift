//
//  Created by Jeffrey Bergier on 2022/01/02.
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

import Model

extension Vessel {
    internal init(cd: CD_ReminderVessel) {
        self.init(id: .init(cd.objectID.uriRepresentation().absoluteString),
                  displayName: cd.raw_displayName,
                  icon: .init(rawImageData: cd.raw_iconImageData,
                              emojiString: cd.raw_iconEmojiString),
                  kind: .init(rawValue: cd.raw_kindString ?? "-1") ?? .plant)
    }
    internal init?(cd: CD_ReminderVessel?) {
        guard let cd = cd else { return nil }
        self.init(cd: cd)
    }
    internal init() {
        self.init(id: .init("FALSE"))
    }
}
