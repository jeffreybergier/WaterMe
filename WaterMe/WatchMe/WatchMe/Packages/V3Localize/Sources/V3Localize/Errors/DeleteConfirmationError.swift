//
//  Created by Jeffrey Bergier on 2022/11/22.
//  Copyright © 2020 Saturday Apps.
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
import V3Model

extension DeleteConfirmationError: UserFacingError {
    // TODO: Complete this
    public var title: Umbrella.LocalizationKey {
        "Delete?"
    }
    public var message: Umbrella.LocalizationKey {
        "For Real?"
    }
    public var dismissTitle: Umbrella.LocalizationKey {
        "Fuck off"
    }
    public var isCritical: Bool {
        false
    }
    public var options: [Umbrella.RecoveryOption] {
        return [
            .init(title: "SERIOUS!",
                  isDestructive: true,
                  perform: { self.onConfirmation(self.request) }),
        ]
    }
}
