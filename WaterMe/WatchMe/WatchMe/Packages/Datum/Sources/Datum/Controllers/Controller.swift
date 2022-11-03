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

import CoreData
import Umbrella
import Settings
import Model

public protocol Controller {
    var kind: ControllerKind { get }
    var syncProgress: CloudKitContainerContinuousProgress? { get }
    // HACK: Needed so the context can be placed into the SwiftUI environment
    var __ENVONLY__managedObjectContext: NSManagedObjectContext { get }
    func newVessel() -> Result<Vessel.アイディ, Error>
    func newReminder(for vessel: Vessel.アイディ) -> Result<Reminder.アイディ, Error>
    func appendNewPerformToReminders(with ids: [Reminder.アイディ]) -> Result<Void, Error>
    func delete(_: Vessel.アイディ) -> Result<Void, Error>
    func delete(_: Reminder.アイディ) -> Result<Void, Error>
}
