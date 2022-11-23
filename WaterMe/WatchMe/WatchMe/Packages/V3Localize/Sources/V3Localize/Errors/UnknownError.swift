//
//  Created by Jeffrey Bergier on 2022/11/23.
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

public struct UnknownError: UserFacingError {
    
    static public var errorDomain = "com.saturdayapps.WaterMe.localize"
    public var errorCode: Int { 1001 }
    
    public init() {}
    
    public var title: Umbrella.LocalizationKey {
        Noun.error.rawValue
    }
    public var message: Umbrella.LocalizationKey {
        Phrase.errorUnknown.rawValue
    }
    public var dismissTitle: Umbrella.LocalizationKey {
        Verb.dismiss.rawValue
    }
    public var isCritical: Bool {
        false
    }
    public var options: [Umbrella.RecoveryOption] {
        return []
    }
}
