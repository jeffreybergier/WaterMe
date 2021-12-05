//
//  CD_ReminderCollection.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/05/21.
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

internal typealias LazyContext = () -> NSManagedObjectContext

internal class CD_ReminderCollection: BaseCollection {

    private let controller: CD_ReminderQuery.Controller
    private let context: LazyContext
    private let transform: (CD_Reminder, @escaping LazyContext) -> Reminder = { CD_ReminderWrapper($0, context: $1) }

    init(_ controller: CD_ReminderQuery.Controller, context: @escaping LazyContext) {
        self.controller = controller
        self.context = context
    }

    subscript(index: Int) -> Reminder? {
        return self.transform(self.controller.object(at: IndexPath(row: index, section: 0)), self.context)
    }

    func count(at index: Int?) -> Int? {
        guard index != nil else { return 1 }
        return self.controller.fetchedObjects?.count
    }

    func index(of reminder: Reminder) -> Int? {
        // swiftlint:disable:next force_cast
        let constant = (reminder as! CD_ReminderWrapper).wrappedObject
        for (idx, loop) in (self.controller.fetchedObjects ?? []).enumerated()  {
            guard constant.objectID == loop.objectID else { continue }
            return idx
        }
        return nil
    }

    func indexOfItem(with identifier: Identifier) -> Int? {
        for (idx, reminder) in (self.controller.fetchedObjects ?? []).enumerated()  {
            if reminder.objectID.uriRepresentation().absoluteString == identifier.uuid {
                return idx
            }
            if reminder.raw_migrated?.raw_realmIdentifier == identifier.uuid {
                return idx
            }
            continue
        }
        return nil
    }
}

internal class CD_ReminderQuery: CollectionQuery {

    typealias Index = Int
    typealias Element = Reminder

    typealias Controller = NSFetchedResultsController<CD_Reminder>
    private let controller: Controller
    private let context: LazyContext
    // swiftlint:disable:next weak_delegate
    private var delegate: UpdatingFetchedResultsControllerDelegate?

    init(_ controller: Controller, context: @escaping LazyContext) {
        self.controller = controller
        self.context = context
    }

    func observe(_ closure: @escaping (ReminderCollectionChange) -> Void) -> ObservationToken {
        self.delegate = .init { [weak self] in
            guard self?.delegate != nil else { return }
            closure(.update($0.transformed()))
        }
        self.controller.delegate = self.delegate
        DispatchQueue.main.async {
            do {
                try self.controller.performFetch()
                closure(.initial(data: AnyCollection(CD_ReminderCollection(self.controller, context: self.context))))
            } catch {
                closure(.error(error: .read))
            }
        }
        return self
    }
}

extension CD_ReminderQuery: ObservationToken {
    func invalidate() {
        self.controller.delegate = nil
        self.delegate = nil
    }
}
