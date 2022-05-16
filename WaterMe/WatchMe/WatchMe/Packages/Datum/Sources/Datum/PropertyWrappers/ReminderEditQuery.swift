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
public struct ReminderEditQuery: DynamicProperty {

    @ObservedObject private var cd_reminder: CD_Reminder
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var errorQ: ErrorQueue

    // TODO: Move controller into the environment
    public init(id: Reminder.アイディ, controller: AnyController) {
        let controller = controller.wrapped as! CD_Controller
        let id = controller.container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: URL(string: id.id)!)!
        let cd_reminder = controller.container.viewContext.object(with: id) as! CD_Reminder
        _cd_reminder = .init(initialValue: cd_reminder)
    }

    public init(_ reminder: Reminder, controller: AnyController) {
        self.init(id: reminder.id, controller: controller)
    }

    public var wrappedValue: Reminder {
        Reminder(cd: self.cd_reminder)
    }
    public var projectedValue: Binding<Reminder> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.cd_reminder.raw_kindString = newValue.kind.rawValue
                self.cd_reminder.raw_descriptionString = newValue.kindDescription
                self.cd_reminder.raw_interval = Int32(newValue.interval)
                self.cd_reminder.raw_isEnabled = newValue.isEnabled
                self.cd_reminder.raw_note = newValue.note
                guard case .failure(let error) = self.context.waterme_save() else { return }
                self.errorQ.value.append(error)
            }
        )
    }
}
