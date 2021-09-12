//
//  BasicController.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/05/17.
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

import UIKit
import Calculate
import CoreData

public func NewBasicController(of kind: ControllerKind) -> Result<BasicController, DatumError> {
    do {
        let bc = try CD_BasicController(kind: kind)
        return .success(bc)
    } catch {
        error.log(as: .emergency)
        return .failure(.loadError)
    }
}

public protocol BasicController: AnyObject {

    static var storeDirectoryURL: URL { get }
    static var storeExists: Bool { get }

    var remindersDeleted: ((Set<ReminderValue>) -> Void)? { get set }
    var reminderVesselsDeleted: ((Set<ReminderVesselValue>) -> Void)? { get set }
    var userDidPerformReminder: ((Set<ReminderValue>) -> Void)? { get set }

    var kind: ControllerKind { get }
    
    @available(iOS 14.0, *)
    var syncProgress: AnyContinousProgress<GenericInitializationError, CloudKitSyncError>? { get }

    // MARK: Create
    func newReminder(for vessel: ReminderVessel) -> Result<Reminder, DatumError>
    func newReminderVessel(displayName: String?, icon: ReminderVesselIcon?) -> Result<ReminderVessel, DatumError>

    // MARK: Read
    func allVessels(sorted: ReminderVesselSortOrder, ascending: Bool) -> Result<AnyCollectionQuery<ReminderVessel, Int>, DatumError>
    func enabledReminders(sorted: ReminderSortOrder, ascending: Bool) -> Result<AnyCollectionQuery<Reminder, Int>, DatumError>
    func groupedReminders() -> Result<AnyCollectionQuery<Reminder, IndexPath>, DatumError>
    func reminderVessel(matching identifier: Identifier) -> Result<ReminderVessel, DatumError>
    func reminder(matching identifier: Identifier) -> Result<Reminder, DatumError>

    // MARK: Update
    func update(displayName: String?, icon: ReminderVesselIcon?, in vessel: ReminderVessel) -> Result<Void, DatumError>
    func update(kind: ReminderKind?, interval: Int?, isEnabled: Bool?, note: String?, in reminder: Reminder) -> Result<Void, DatumError>
    func appendNewPerformToReminders(with identifiers: [Identifier]) -> Result<Void, DatumError>

    // MARK: Delete
    func delete(vessel: ReminderVessel) -> Result<Void, DatumError>
    func delete(reminder: Reminder) -> Result<Void, DatumError>
}

public protocol HasBasicController {
    var basicRC: BasicController? { get set }
}

extension HasBasicController {
    public mutating func configure(with basicRC: BasicController?) {
        guard let basicRC = basicRC else { return }
        self.basicRC = basicRC
    }
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

internal func testing_NewRLMBasicController() -> Result<BasicController, DatumError> {
    do {
        let bc = try RLM_BasicController(kind: .__testing_inMemory)
        return .success(bc)
    } catch {
        return .failure(.loadError)
    }
}

internal func testing_NewCDBasicController() -> Result<BasicController, DatumError> {
    do {
        let bc = try CD_BasicController(kind: .__testing_inMemory)
        return .success(bc)
    } catch {
        return .failure(.loadError)
    }
}
