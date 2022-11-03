//
//  Created by Jeffrey Bergier on 2022/02/06.
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

//
// ConveniencePropertyWrappers, in general make it easy to assemble Theme
// and ViewModifier elements into an easy to consume format for each view.
//

// Ensures the PR's stay mildly consistent in terms of public API
public protocol ConveniencePropertyWrapper {
    /// Specifies all the color and styles for a view
    /// - Parameters:
    ///   - size: Override for value provided from environment
    ///   - theme: Override for value provided from environment
    init(size: Size?, theme: Theme?)
}
