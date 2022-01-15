//
//  Created by Jeffrey Bergier on 2022/01/01.
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

@propertyWrapper
public struct Nav: DynamicProperty {

    @SceneStorage("Navigation") private var state: Navigation.State = .rootアList
    
    public init() {}

    public var wrappedValue: Navigation {
        get { .init(self.state) }
        nonmutating set { self.state = newValue.state }
    }
    
    public var projectedValue: Binding<Navigation> {
        Binding {
            self.wrappedValue
        } set: { newValue in
            self.state = newValue.state
        }
    }
}
