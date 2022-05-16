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
import Model

@propertyWrapper
public struct VesselEditReminderQuery: DynamicProperty {
    
    @FetchRequest private var data: FetchedResults<CD_Reminder>
    @Environment(\.managedObjectContext) private var context
    
    public init(id: Vessel.アイディ, controller: AnyController) {
        let controller = controller.wrapped as! CD_Controller
        let id = controller.container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: URL(string: id.id)!)!
        let sort = NSSortDescriptor(keyPath: \CD_Reminder.raw_dateCreated, ascending: true)
        let pred = NSPredicate(format: "%K == %@", #keyPath(CD_Reminder.raw_vessel), id)
        let fr = FetchRequest<CD_Reminder>(sortDescriptors: [sort],
                                           predicate:  pred,
                                           animation: .default)
        _data = fr
    }
    
    public var wrappedValue: AnyRandomAccessCollection<Reminder> {
        TransformCollection(collection: self.data) { item in
            Reminder(cd: item)
        }.eraseToAnyRandomAccessCollection()
    }
}
