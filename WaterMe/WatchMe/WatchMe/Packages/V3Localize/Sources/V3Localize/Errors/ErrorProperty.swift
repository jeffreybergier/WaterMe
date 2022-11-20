//
//  Created by Jeffrey Bergier on 2022/11/20.
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

import SwiftUI
import Umbrella
import V3Error

@propertyWrapper
public struct UserFacingErrors: DynamicProperty {

    @Errors private var store
    
    public init() { }
    
    public var wrappedValue: some RandomAccessCollection<any UserFacingError> {
        TransformCollection(collection: self.store,
                            transform: { $0.decode })
    }
    
    public func append(_ error: UserFacingError & CodecProtocol) {
        self.store.append(error.encode)
    }
}
