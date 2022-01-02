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
public struct ReminderListQuery: DynamicProperty {
    
    @FetchRequest(sortDescriptors: [
        NSSortDescriptor(keyPath: \CD_Reminder.raw_nextPerformDate,
                         ascending: false)
    ], animation: .default)
    private var data: FetchedResults<CD_Reminder>
    @Environment(\.managedObjectContext) private var context
    
    public init() {}
    
    public var wrappedValue: AnyRandomAccessCollection<Binding<Reminder>> {
        get {
            AnyRandomAccessCollection(
                TransformCollection(collection: self.data) { item in
                    Binding(
                        get: {
                            Reminder(cd: item)
                        },
                        set: { newItem in
                            // TODO: This fires twice for some reason
//                            item.cd_title = newItem.title
//                            item.cd_dateModified = newItem.dateModified
//                            do {
//                                try context.save()
//                                print("Success: \(newItem.title)")
//                            } catch {
//                                print(error)
//                            }
                        }
                    )
                }
            )
        }
    }
}
