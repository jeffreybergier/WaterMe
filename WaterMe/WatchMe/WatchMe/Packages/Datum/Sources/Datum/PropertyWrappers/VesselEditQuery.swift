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

import SwiftUI
import CoreData
import Model
import Umbrella

@propertyWrapper
public struct VesselEditQuery: DynamicProperty {

    @Environment(\.managedObjectContext) private var context
    @ObservedObject private var cd_reminderVessel: CD_ReminderVessel
    @EnvironmentObject private var errorQ: ErrorQueue

    // TODO: Move controller into the environment
    public init(id: Vessel.アイディ, controller: AnyController) {
        let controller = controller.wrapped as! CD_Controller
        let id = controller.container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: URL(string: id.id)!)!
        let cd_vessel = controller.container.viewContext.object(with: id) as! CD_ReminderVessel
        _cd_reminderVessel = .init(initialValue: cd_vessel)
    }

    public init(_ reminder: Reminder, controller: AnyController) {
        self.init(id: reminder.vesselID!, controller: controller)
    }

    public var wrappedValue: Vessel {
        get { Vessel(cd: self.cd_reminderVessel) }
        nonmutating set { self.update(with: newValue) }
    }
    public var projectedValue: Binding<Vessel> {
        Binding(
            get: { self.wrappedValue },
            set: { self.update(with: $0) }
        )
    }

    private func update(with newValue: Vessel) {
        self.cd_reminderVessel.raw_displayName = newValue.displayName
        self.cd_reminderVessel.raw_kindString = newValue.kind.rawValue
        self.cd_reminderVessel.raw_iconEmojiString = newValue.icon?.emoji
        self.cd_reminderVessel.raw_iconImageData = newValue.icon?.dataValue
        guard case .failure(let error) = self.context.waterme_save() else { return }
        self.errorQ.value.append(error)
    }
}
