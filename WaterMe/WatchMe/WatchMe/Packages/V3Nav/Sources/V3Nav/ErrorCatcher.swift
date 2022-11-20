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

public struct ErrorCatcher: ViewModifier {
    
    @ErrorStorage private var store
    
    public init() { }
    
    public func body(content: Content) -> some View {
        content.environment(\.errorResponder) { error in
            guard let error = error as? CodableErrorConvertible else {
                assertionFailure("Unsupported Error: \(String(describing: error))")
                return
            }
            assert(type(of: error) != CodableError.self,
                   "CodableError: DoubleEncoding: \(String(describing: error))")
            self.store.append(error.encode)
        }
    }
    
}
