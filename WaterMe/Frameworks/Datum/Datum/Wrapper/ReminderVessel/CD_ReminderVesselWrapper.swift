//
//  CD_ReminderVesselWrapper.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/05/20.
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

import CoreData

internal struct CD_ReminderVesselWrapper: ReminderVessel {
    internal let wrappedObject: CD_ReminderVessel
    internal let context: LazyContext
    internal init(_ wrappedObject: CD_ReminderVessel, context: @escaping LazyContext) {
        self.wrappedObject = wrappedObject
        self.context = context
    }
    
    public var uuid: String { self.wrappedObject.objectID.uriRepresentation().absoluteString }
    public var displayName: String? { self.wrappedObject.raw_displayName }
    public var icon: ReminderVesselIcon? { self.wrappedObject.icon }
    public var kind: ReminderVesselKind { self.wrappedObject.kind }
    public var isModelComplete: ModelCompleteError? { self.wrappedObject.isModelComplete }
    public var shortLabelSafeDisplayName: String? { self.wrappedObject.shortLabelSafeDisplayName }
    
    func observe(_ block: @escaping (ReminderVesselChange) -> Void) -> ObservationToken {
        let queue = DispatchQueue.main
        let vessel = self.wrappedObject
        let token1 = vessel.observe(\.raw_displayName) { _, _ in
            queue.async { block(.change(.init(changedDisplayName: true))) }
        }
        let token2 = vessel.observe(\.raw_iconEmojiString) { _, _ in
            queue.async { block(.change(.init(changedIconEmoji: true))) }
        }
        let token3 = vessel.observe(\.raw_iconImageData) { _, _ in
            queue.async { block(.change(.init(changedIconEmoji: true))) }
        }
        let token4 = vessel.observe(\.raw_kindString) { _, _ in
            queue.async { block(.change(.init(changedPointlessBloop: true))) }
        }
        
        let token5 = NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange,
                                                            object: nil,
                                                            queue: nil)
        { [weak wrappedObject] notification in
            guard let wrappedObject = wrappedObject else { return }
            let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? NSSet
            for object in deletedObjects ?? [] {
                let object = object as? NSManagedObject
                guard object?.objectID == wrappedObject.objectID else { continue }
                queue.async { block(.deleted) }
                return
            }
        }
        
        return Token.wrap { [token1, token2, token3, token4, Token.wrap { token5 }] }
    }
    
    func observeReminders(_ block: @escaping (ReminderCollectionChange) -> Void) -> ObservationToken {
        let request = CD_Reminder.request
        request.predicate = NSPredicate(format: "\(#keyPath(CD_Reminder.raw_vessel)) == %@", self.wrappedObject)
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(CD_Reminder.raw_dateCreated), ascending: false)]
        let context = self.context()
        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        let query = CD_ReminderQuery(controller, context: self.context)
        return query.observe(block)
    }
}
