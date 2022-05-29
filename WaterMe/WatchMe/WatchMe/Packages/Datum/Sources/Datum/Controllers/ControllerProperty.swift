//
//  Created by Jeffrey Bergier on 2022/03/26.
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
import ServerlessLogger
import Umbrella
import Settings

@propertyWrapper
public struct ControllerProperty: DynamicProperty {
    
    public typealias Environment = BlackBox<Controller?>
    
    public static func newEnvironment(of kind: ControllerKind) -> (Environment, Error?) {
        do {
            let controller = try CD_Controller(kind: kind)
            return (BlackBox(controller, isObservingValue: false), nil)
        } catch {
            error.log(as: .emergency)
            return (BlackBox(nil, isObservingValue: false), .load)
        }
    }
    
    @EnvironmentObject private var controller: BlackBox<Controller?>
    internal var cdController: CD_Controller {
        return self.controller.value as! CD_Controller
    }
    
    public init() { }
    
    public var wrappedValue: Controller {
        self.controller.value!
    }
    
}
