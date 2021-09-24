//
//  CD_ReminderVesselCollection.swift
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

internal class CD_ReminderVesselCollection: BaseCollection {
    
    private let controller: CD_ReminderVesselQuery.Controller
    private var context: LazyContext!
    
    init(_ controller: CD_ReminderVesselQuery.Controller, context: @escaping LazyContext) {
        self.controller = controller
        self.context = context
    }
        
    subscript(index: Int) -> ReminderVessel? {
        let reminderVessel = self.controller.object(at: IndexPath(row: index, section: 0))
        return CD_ReminderVesselWrapper(reminderVessel,
                                        context: self.context)
    }
    
    func count(at index: Int?) -> Int? {
        guard index != nil else { return 1 }
        return self.controller.fetchedObjects?.count
    }

    func index(of lhs: ReminderVessel) -> Int? {
        // swiftlint:disable:next force_cast
        let lhs = (lhs as! CD_ReminderVesselWrapper).wrappedObject
        for (idx, rhs) in (self.controller.fetchedObjects ?? []).enumerated()  {
            guard lhs.objectID == rhs.objectID else { continue }
            return idx
        }
        return nil
    }

    func indexOfItem(with identifier: Identifier) -> Int? {
        for (idx, vessel) in (self.controller.fetchedObjects ?? []).enumerated()  {
            if vessel.objectID.uriRepresentation().absoluteString == identifier.uuid {
                return idx
            }
            if vessel.raw_migrated?.raw_realmIdentifier == identifier.uuid {
                return idx
            }
            continue
        }
        return nil
    }
}

internal class CD_ReminderVesselQuery: CollectionQuery {
    
    typealias Controller = NSFetchedResultsController<CD_ReminderVessel>
    
    private let controller: Controller
    private let context: LazyContext
    // swiftlint:disable:next weak_delegate
    private var delegate: UpdatingFetchedResultsControllerDelegate?
    
    init(_ controller: Controller, context: @escaping LazyContext) {
        self.controller = controller
        self.context = context
    }
    
    func observe(_ block: @escaping (CollectionChange<AnyCollection<ReminderVessel, Int>, Int>) -> Void) -> ObservationToken {
        self.delegate = .init { block(.update($0.transformed())) }
        self.controller.delegate = self.delegate
        DispatchQueue.main.async {
            do {
                try self.controller.performFetch()
                let collection = CD_ReminderVesselCollection(self.controller, context: self.context)
                block(.initial(data: AnyCollection(collection)))
            } catch {
                block(.error(error: .readError))
            }
        }
        return self
    }
}

extension CD_ReminderVesselQuery: ObservationToken {
    func invalidate() {
        self.controller.delegate = nil
        self.delegate = nil
    }
}
