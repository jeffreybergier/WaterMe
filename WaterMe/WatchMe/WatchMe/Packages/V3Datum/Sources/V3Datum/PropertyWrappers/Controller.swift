//
//  Created by Jeffrey Bergier on 2022/07/10.
//
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
import V3Settings

@propertyWrapper
public struct Controller: DynamicProperty {
    
    public typealias Environment = ObserveBox<Result<ControllerProtocol, Error>>
    @EnvironmentObject private var environment: Environment
    
    public init() { }
    
    public var wrappedValue: ControllerProtocol {
        self.environment.value.value!
    }
    
    public var error: Error? {
        self.environment.value.error
    }
    
    internal var cd: CD_Controller {
        self.environment.value.value as! CD_Controller
    }
}

extension Controller {
    public static func newEnvironment(_ kind: ControllerKind) -> Environment {
        // TODO: Change to not be inMemory
        do {
            let controller = try CD_Controller(kind: kind)
            return .init(.success(controller))
        } catch let error as Error {
            return .init(.failure(error))
        } catch {
            NSLog("Whoa")
            fatalError()
        }
    }
}
