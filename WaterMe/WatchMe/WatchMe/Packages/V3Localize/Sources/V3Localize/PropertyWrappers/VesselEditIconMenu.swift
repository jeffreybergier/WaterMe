//
//  Created by Jeffrey Bergier on 2022/11/27.
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

extension VesselEdit {
    @propertyWrapper
    public struct IconMenu: DynamicProperty {
        
        // swiftlint:disable:next nesting
        public struct Value {
            public var title:       LocalizedString
            public var emoji:       ActionLocalization
            public var camera:      ActionLocalization
            public var library:     ActionLocalization
            public var viewCurrent: ActionLocalization
            public var message:     ActionLocalization
            
            internal init(_ b: Bundle) {
                self.title       = b.localized(key: Noun.emptyString.rawValue)
                self.emoji       = Action.sourceEmoji.localized(b)
                self.library     = Action.sourceLibrary.localized(b)
                self.viewCurrent = Action.viewPhoto.localized(b)
                self.message     = Action.editPhotoMessage.localized(b)
                // TODO: Replace with real logic based on permissions / device
                self.camera      = false ? Action.sourceCamera.localized(b)
                                         : Action.sourceCameraLock.localized(b)
            }
        }
        
        @Environment(\.bundle) private var bundle

        public init() {}
        
        public var wrappedValue: Value {
            Value(self.bundle)
        }
    }
}
