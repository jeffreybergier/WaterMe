//
//  Created by Jeffrey Bergier on 2021/12/31.
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

import Foundation
import CoreData

public func NewController(of kind: ControllerKind) -> AnyController? {
    do {
        let controller = try CD_Controller(kind: kind)
        return AnyController(controller)
    } catch {
        error //.log(as: .emergency)
        return nil
    }
}

public class AnyController: Controller {
    
    internal let wrapped: AnyObject
    private let _kind: () -> ControllerKind
    private let ___ENVONLY__managedObjectContext: () -> NSManagedObjectContext
    
    public var kind: ControllerKind { _kind() }
    public var __ENVONLY__managedObjectContext: NSManagedObjectContext { ___ENVONLY__managedObjectContext() }
    
    internal init<C: Controller>(_ controller: C) {
        _kind = { controller.kind }
        ___ENVONLY__managedObjectContext = { controller.__ENVONLY__managedObjectContext }
        self.wrapped = controller
    }
}

public protocol Controller: ObservableObject {
    var kind: ControllerKind { get }
    // HACK: Needed so the context can be placed into the SwiftUI environment
    var __ENVONLY__managedObjectContext: NSManagedObjectContext { get }
}

public enum ControllerKind: RawRepresentable {

    case local
    case sync
    case __testing_inMemory
    case __testing_withClass(NSPersistentContainer.Type)

    public var rawValue: Bool {
        switch self {
        case .local:
            return false
        case .sync:
            return true
        case .__testing_inMemory, .__testing_withClass:
            fatalError("RawValue unsupported while testing")
        }
    }

    public init(rawValue: Bool) {
        self = rawValue ? .sync : .local
    }
}
