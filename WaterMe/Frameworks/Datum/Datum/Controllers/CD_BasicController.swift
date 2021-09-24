//
//  CD_BasicController.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/05/16.
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
import UIKit
import Calculate

// swiftlint:disable file_length

// swiftlint:disable:next type_body_length
internal class CD_BasicController: BasicController {

    private class func container(kind: ControllerKind) -> NSPersistentContainer? {
        // debug only sanity checks
        assert(Thread.isMainThread)

        guard
            let url = Bundle(for: CD_BasicController.self)
                            .url(forResource: "WaterMe", withExtension: "momd"),
            let mom = NSManagedObjectModel(contentsOf: url)
        else {
            "Unable to load MOM from application bundle".log(as: .emergency)
            return nil
        }

        switch kind {
        case .sync:
            if #available(iOS 14.0, *) {
                return WaterMe_PersistentSyncContainer(name: "WaterMe", managedObjectModel: mom)
            } else {
                let message = "Attempted to load Sync container from iOS 13 or lower."
                message.log(as: .info)
                fallthrough
            }
        case .local:
            let container = WaterMe_PersistentContainer(name: "WaterMe", managedObjectModel: mom)
            let description = container.persistentStoreDescriptions.first!
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            return container
        case .__testing_inMemory:
            // when testing make in-memory container
            let randomName = String(Int.random(in: 100_000...1_000_000))
            let container = WaterMe_PersistentContainer(name: randomName, managedObjectModel: mom)
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
            return container
        case .__testing_withClass(let _type):
            return _type.init(name: "WaterMe", managedObjectModel: mom)
        }
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    init(kind: ControllerKind) throws {
        // debug only sanity checks
        assert(Thread.isMainThread)

        guard let container = CD_BasicController.container(kind: kind)
            else { throw DatumError.loadError }

        switch kind {
        case .local, .sync:
            type(of: self).copySampleDBIfNeeded()
        case .__testing_inMemory, .__testing_withClass:
            break // don't copy sameple DB when testing
        }

        let lock = DispatchSemaphore(value: 0)
        var error: Error?
        container.loadPersistentStores { _, _error in
            error = _error
            lock.signal()
        }
        lock.wait()

        guard error == nil else { throw error! }
        container.viewContext.automaticallyMergesChangesFromParent = true

        switch kind {
        case .local, .sync:
            guard #available(iOS 14.0, *), container is NSPersistentCloudKitContainer
            else { self._syncProgress = nil; break; }
            self._syncProgress = AnyContinousProgress(CloudKitContainerContinuousProgress(container))
        case .__testing_inMemory, .__testing_withClass:
            self._syncProgress = nil
        }

        // Set properties
        self.kind = kind
        self.container = container

        // Configure maintenance monitor
        self.maintenance_changeToken = self.maintenance_changeMonitor()
        if case .local = self.kind {
            UserDefaults.standard.didRunWithoutCloudSync = true
        }

        // Observe sync changes to perform maintenance
        if #available(iOS 14.0, *) {
            self.maintenance_syncToken = self.syncProgress?.objectWillChange
                .debounce(for: .seconds(3), scheduler: RunLoop.main)
                .sink { [weak self] _ in
                    guard
                        let self = self,
                        self.syncProgress?.progress.fractionCompleted == 1
                    else { return }
                    "Performing post syncing maintenance".log(as: .debug)
                    // Perform maintenance and log any errors
                    self.maintenance_fixDates()
                        .reduce(self.maintenance_deleteOrphanedReminders)
                        .reduce(self.maintenance_oneTrueVesselShare)
                        .reduce(self.maintenance_fixOrphanedVessels(share:))
                        .reduce(self.maintenance_massageAllEntries)
                        .error?.log()
                }
        }

        //
        // DEBUG ONLY
        // initialize the CloudKit schema
        // only do this once per change to CD MOM
        //
        #if DEBUG
        guard
            #available(iOS 14.0, *),
            let container = container as? NSPersistentCloudKitContainer
        else { return }
        let configureCKSchema = false
        if configureCKSchema {
            // swiftlint:disable:next force_try
            try! container.initializeCloudKitSchema(options: [.printSchema])
            fatalError("Cannot continue while using: initializeCloudKitSchema")
        }
        #endif
    }

    // MARK: Properties

    internal var remindersDeleted: ((Set<ReminderValue>) -> Void)?
    internal var reminderVesselsDeleted: ((Set<ReminderVesselValue>) -> Void)?
    internal var userDidPerformReminder: ((Set<ReminderValue>) -> Void)?

    // Internal only for testing. Should be private.
    internal let container: NSPersistentContainer
    internal let kind: ControllerKind
    private var maintenance_changeToken: Any?
    private var maintenance_syncToken: Any?
    private let _syncProgress: AnyObject?
    @available(iOS 14.0, *)
    internal var syncProgress: AnyContinousProgress<GenericInitializationError, CloudKitSyncError>? {
        _syncProgress as? AnyContinousProgress<GenericInitializationError, CloudKitSyncError>
    }

    // MARK: Create

    func newReminder(for vessel: ReminderVessel) -> Result<Reminder, DatumError> {
        // swiftlint:disable:next force_cast
        let vessel = (vessel as! CD_ReminderVesselWrapper).wrappedObject
        let context = self.container.viewContext

        // debug only sanity checks
        assert(Thread.isMainThread)
        assert(context === vessel.managedObjectContext!)

        let newReminder = CD_Reminder(context: context)
        context.insert(newReminder)
        // core data hooks up the inverse relationship
        newReminder.raw_vessel = vessel
        return context.waterme_save().map {
            CD_ReminderWrapper(newReminder, context: { self.container.viewContext })
        }
    }

    func newReminderVessel(displayName: String?,
                           icon: ReminderVesselIcon?)
                           -> Result<ReminderVessel, DatumError>
    {
        // debug only sanity checks
        assert(Thread.isMainThread)

        // get vesselshare or bail
        let vesselShareResult = self.maintenance_oneTrueVesselShare()
        let vesselShare: CD_VesselShare
        switch vesselShareResult {
        case .success(let vs):
            vesselShare = vs
        case .failure(let error):
            return .failure(error)
        }

        // create new vessel
        let context = self.container.viewContext
        let vessel = CD_ReminderVessel(context: context)

        // enforce at least 1 reminder
        let newReminder = CD_Reminder(context: context)
        context.insert(newReminder)
        context.insert(vessel)

        // core data hooks up the inverse relationship
        newReminder.raw_vessel = vessel
        if let displayName = displayName {
            vessel.raw_displayName = displayName
        }
        if let icon = icon {
            vessel.icon = icon
        }
        vessel.raw_share = vesselShare

        // save
        return context.waterme_save().map {
            CD_ReminderVesselWrapper(vessel, context: { self.container.viewContext })
        }
    }

    // MARK: Read

    internal func allVessels(sorted: ReminderVesselSortOrder,
                             ascending: Bool)
                             -> Result<AnyCollectionQuery<ReminderVessel, Int>, DatumError>
    {
        // debug only sanity checks
        assert(Thread.isMainThread)

        let context = self.container.viewContext
        let fr = CD_ReminderVessel.request
        fr.sortDescriptors = [CD_ReminderVessel.sortDescriptor(for: sorted, ascending: ascending)]
        let frc = NSFetchedResultsController<CD_ReminderVessel>(fetchRequest: fr,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        let query = CD_ReminderVesselQuery(frc, context: { self.container.viewContext })
        return .success(AnyCollectionQuery(query))
    }

    func enabledReminders(sorted: ReminderSortOrder,
                          ascending: Bool)
                          -> Result<AnyCollectionQuery<Reminder, Int>, DatumError>
    {
        // debug only sanity checks
        assert(Thread.isMainThread)

        let context = self.container.viewContext
        let fr = CD_Reminder.request
        fr.sortDescriptors = [CD_Reminder.sortDescriptor(for: sorted, ascending: ascending)]
        fr.predicate = NSPredicate(format: "%K == YES", #keyPath(CD_Reminder.raw_isEnabled))
        let frc = NSFetchedResultsController(fetchRequest: fr,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        let query = CD_ReminderQuery(frc, context: { self.container.viewContext })
        return .success(AnyCollectionQuery(query))
    }

    internal func groupedReminders() -> Result<AnyCollectionQuery<Reminder, IndexPath>, DatumError> {
        // debug only sanity checks
        assert(Thread.isMainThread)

        var failure: DatumError?
        let _queries = ReminderSection.allCases.compactMap
        { section -> (ReminderSection, AnyCollectionQuery<Reminder, Int>)? in
            let result = self.reminders(in: section)
            switch result {
            case .failure(let error):
                failure = error
                return nil
            case .success(let query):
                return (section, query)
            }
        }
        if let failure = failure { return .failure(failure) }
        let queries = Dictionary(_queries) { (first, _) in first }
        let query = GroupedCollection(queries: queries)
        return .success(AnyCollectionQuery(query))
    }

    private func reminders(in section: ReminderSection,
                           sorted: ReminderSortOrder = .nextPerformDate,
                           ascending: Bool = true)
                           -> Result<AnyCollectionQuery<Reminder, Int>, DatumError>
    {
        // debug only sanity checks
        assert(Thread.isMainThread)

        let enabledPredicate = NSPredicate(format: "%K == YES", #keyPath(CD_Reminder.raw_isEnabled))
        let disabledPredicate = NSPredicate(format: "%K == NO", #keyPath(CD_Reminder.raw_isEnabled))
        let normalPredicate: (DateInterval) -> NSPredicate = { range in
            return NSCompoundPredicate(andPredicateWithSubpredicates: [
                enabledPredicate,
                NSPredicate(format: "%K >= %@", #keyPath(CD_Reminder.raw_nextPerformDate), (range.start as NSDate)),
                NSPredicate(format: "%K < %@", #keyPath(CD_Reminder.raw_nextPerformDate), (range.end as NSDate))
            ])
        }

        let predicate: NSPredicate
        switch section {
        case .disabled:
            predicate = disabledPredicate
        case .later, .thisWeek, .today, .tomorrow:
            predicate = normalPredicate(section.dateInterval)
        case .late:
            let neverPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                enabledPredicate,
                NSPredicate(format: "%K == nil", #keyPath(CD_Reminder.raw_nextPerformDate))
            ])
            predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
                normalPredicate(section.dateInterval),
                neverPredicate
            ])
        }

        let fetchRequest = CD_Reminder.request
        fetchRequest.sortDescriptors = [CD_Reminder.sortDescriptor(for: sorted, ascending: ascending)]
        fetchRequest.predicate = predicate
        let context = self.container.viewContext
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        let query = CD_ReminderQuery(controller, context: { self.container.viewContext })
        return .success(AnyCollectionQuery(query))
    }

    func reminderVessel(matching id: Identifier) -> Result<ReminderVessel, DatumError> {
        return __genericSearch(matching: id).map { (object: CD_ReminderVessel) in
            return CD_ReminderVesselWrapper(object, context: { self.container.viewContext })
        }
    }

    func reminder(matching id: Identifier) -> Result<Reminder, DatumError> {
        return __genericSearch(matching: id).map { (object: CD_Reminder) in
            return CD_ReminderWrapper(object, context: { self.container.viewContext })
        }
    }

    // swiftlint:disable:next function_body_length
    private func __genericSearch<T: CD_Base>(matching id: Identifier) -> Result<T, DatumError> {
        let coordinator = self.container.persistentStoreCoordinator
        let context = self.container.viewContext

        // debug only sanity checks
        assert(Thread.isMainThread)

        do {
            if id.uuid.starts(with: "x-coredata://"), let url = URL(string: id.uuid) {
                // Core Data reference
                guard let id = coordinator.managedObjectID(forURIRepresentation: url)
                    else { return .failure(.objectDeleted) }
                let _object = try context.existingObject(with: id)
                // if the object is the wrong type, log as an error
                guard let object = _object as? T else {
                    let e = "found: \(type(of: _object)) != expected: \(T.self))"
                    assertionFailure(e)
                    e.log()
                    return .failure(.objectDeleted)
                }
                return .success(object)
            } else if UUID(uuidString: id.uuid) != nil {
                // Migrated Legacy Realm Reference
                let req = NSFetchRequest<NSFetchRequestResult>(entityName: T.entityName)
                let kp = #keyPath(CD_Base.raw_migrated.raw_realmIdentifier)
                req.predicate = .init(format: "%K == %@", kp, id.uuid)
                let results = try context.fetch(req)
                let count = results.count
                // if we had no results, return object deleted
                guard count > 0 else { return .failure(.objectDeleted) }
                // if we had more than 1 result, just log this as an error
                if count > 1 {
                    let e = ("\(T.self), id: \(id.uuid), count: \(count): "
                           + "There should only be 1 match")
                    assertionFailure(e)
                    e.log()
                }
                // if the object is the wrong type, log this as an error
                let _object = results[0]
                guard let object = _object as? T else {
                    let e = "found: \(type(of: _object)) != expected: \(T.self))"
                    assertionFailure(e)
                    e.log()
                    return .failure(.objectDeleted)
                }
                return .success(object)
            } else {
                let e = "\(id.uuid): does not appear to be Core Data or Realm identifier"
                assertionFailure(e)
                e.log()
                return .failure(.objectDeleted)
            }
        } catch {
            assertionFailure("\(error)")
            error.log()
            return .failure(.loadError)
        }
    }

    // MARK: Update

    func update(displayName: String?,
                icon: ReminderVesselIcon?,
                in vessel: ReminderVessel) -> Result<Void, DatumError>
    {
        let context = self.container.viewContext
        // swiftlint:disable:next force_cast
        let vessel = (vessel as! CD_ReminderVesselWrapper).wrappedObject

        // debug only sanity checks
        assert(Thread.isMainThread)
        assert(context === vessel.managedObjectContext)

        var somethingChanged = false
        if let displayName = displayName, vessel.raw_displayName != displayName {
            somethingChanged = true
            vessel.raw_displayName = displayName
        }
        if let icon = icon, icon != vessel.icon {
            somethingChanged = true
            vessel.icon = icon
        }
        guard somethingChanged else { return .success(()) }
        // swiftlint:disable:next force_cast
        vessel.raw_reminders?.forEach { ($0 as! CD_Base).raw_bloop.toggle() }
        return context.waterme_save()
    }

    func update(kind: ReminderKind?,
                interval: Int?,
                isEnabled: Bool?,
                note: String?,
                in reminder: Reminder) -> Result<Void, DatumError>
    {
        let context = self.container.viewContext
        // swiftlint:disable:next force_cast
        let reminder = (reminder as! CD_ReminderWrapper).wrappedObject

        // debug only sanity checks
        assert(Thread.isMainThread)
        assert(context === reminder.managedObjectContext)

        var somethingChanged = false
        if let kind = kind, kind != reminder.kind {
            somethingChanged = true
            reminder.kind = kind
        }
        if let interval = interval {
            let converted = Int32(interval)
            if converted != reminder.raw_interval {
                somethingChanged = true
                reminder.raw_interval = converted
                reminder.updateDates()
            }
        }
        if let isEnabled = isEnabled, isEnabled != reminder.raw_isEnabled {
            somethingChanged = true
            reminder.raw_isEnabled = isEnabled
        }
        if let note = note, note != reminder.raw_note {
            somethingChanged = true
            reminder.raw_note = note
        }
        guard somethingChanged else { return .success(()) }
        reminder.raw_vessel?.raw_bloop.toggle()
        return context.waterme_save()
    }

    func appendNewPerformToReminders(with ids: [Identifier]) -> Result<Void, DatumError> {
        // debug only sanity checks
        assert(Thread.isMainThread)

        let results: [Result<CD_Reminder, DatumError>] = ids.map(__genericSearch(matching:))
        let reminders = results.compactMap { try? $0.get() }
        guard reminders.count == ids.count else { return .failure(.objectDeleted) }

        let context = self.container.viewContext

        reminders.forEach { reminder in
            let perform = CD_ReminderPerform(context: context)
            context.insert(perform)
            // core data hooks up the inverse relationship
            perform.raw_reminder = reminder
            reminder.updateDates(withAppendedPerformDate: perform.raw_date)
        }

        return context.waterme_save()
            .reduce(self.maintenance_fixDates)
            .reduce(self.maintenance_deleteOrphanedReminders)
            .reduce(self.maintenance_oneTrueVesselShare)
            .reduce(self.maintenance_fixOrphanedVessels(share:))
    }

    // MARK: Delete

    func delete(vessel: ReminderVessel) -> Result<Void, DatumError> {
        let context = self.container.viewContext
        // swiftlint:disable:next force_cast
        let vessel = (vessel as! CD_ReminderVesselWrapper).wrappedObject

        // debug only sanity checks
        assert(Thread.isMainThread)
        assert(context === vessel.managedObjectContext)

        context.delete(vessel)
        return context.waterme_save()
    }

    func delete(reminder: Reminder) -> Result<Void, DatumError> {
        let context = self.container.viewContext
        // swiftlint:disable:next force_cast
        let reminder = (reminder as! CD_ReminderWrapper).wrappedObject

        // debug only sanity checks
        assert(Thread.isMainThread)
        assert(context === reminder.managedObjectContext)

        guard let vessel = reminder.raw_vessel else {
            context.delete(reminder)
            return context.waterme_save()
        }

        let reminderCount = vessel.raw_reminders?.count ?? 0
        guard reminderCount >= 2 else {
            return .failure(.unableToDeleteLastReminder)
        }

        context.delete(reminder)
        return context.waterme_save()
    }

    deinit {
        guard let maintainanceToken = self.maintenance_changeToken else { return }
        NotificationCenter.default.removeObserver(maintainanceToken)
    }
}

extension CD_BasicController {
    fileprivate func maintenance_changeMonitor() -> Any {
        return NotificationCenter.default.addObserver(forName: .NSManagedObjectContextWillSave,
                                                      object: nil,
                                                      queue: nil)
        { [weak self] notification in
            guard
                let context = notification.object as? NSManagedObjectContext,
                let self = self
            else {
                assertionFailure("Core Data Dates Not Updated")
                return
            }

            // Capture Deleted Values for API Contract
            // This must be done now because they will be deleted soon
            let performedReminders = context.insertedObjects
                .compactMap { ReminderValue(reminder: ($0 as? CD_ReminderPerform)?.raw_reminder) }
            let deletedReminders = context.deletedObjects
                .compactMap { ReminderValue(reminder: $0 as? CD_Reminder) }
            let deletedReminderVessels = context.deletedObjects
                .compactMap { ReminderVesselValue(reminderVessel: $0 as? CD_ReminderVessel) }

            // Now, Dispatch because we want CoreData to save
            // Then we can update any API Contracts
            DispatchQueue.main.async {
                if !performedReminders.isEmpty {
                    self.userDidPerformReminder?(Set(performedReminders))
                }
                if !deletedReminders.isEmpty {
                    self.remindersDeleted?(Set(deletedReminders))
                }
                if !deletedReminderVessels.isEmpty {
                    self.reminderVesselsDeleted?(Set(deletedReminderVessels))
                }
            }
        }
    }

    fileprivate func maintenance_massageAllEntries() -> Result<Void, DatumError> {
        guard UserDefaults.standard.didRunWithoutCloudSync else {
            return .success(())
        }
        do {
            let fetchRequest = CD_Base.requestBase
            let context = self.container.viewContext
            let data = try context.fetch(fetchRequest)
            data.forEach { $0.raw_bloop.toggle() }
            try context.save()
            UserDefaults.standard.didRunWithoutCloudSync = false
            return .success(())
        } catch {
            error.log()
            return .failure(.maintenanceError)
        }
    }

    // have to make 2 functions because of type issues in maintenance token code in INIT
    fileprivate func maintenance_oneTrueVesselShare() -> Result<CD_VesselShare, DatumError> {
        return self.maintenance_oneTrueVesselShare(context: nil)
    }

    /* internal for migration only */
    internal func maintenance_oneTrueVesselShare(context: NSManagedObjectContext?) -> Result<CD_VesselShare, DatumError> {
        let context = context ?? self.container.viewContext
        do {
            // Clean up any errors caused by weird syncing
            // 1. Fetch all VesselShare objects
            let fetchRequest = CD_VesselShare.request
            let fetchResult = try context.fetch(fetchRequest)
            switch fetchResult.count {
            case 0:
                let share = CD_VesselShare(context: context)
                context.insert(share)
                try context.save()
                "0 VesselShares present, but was able to create".log(as: .warning)
                return .success(share)
            case 1:
                let originalVesselShare = fetchResult[0]
                return .success(originalVesselShare)
            default:
                // 1. Find the vesselShare with highest count of vessels
                let sorted = fetchResult.sorted(by: { $0.raw_vessels?.count ?? 0 > $1.raw_vessels?.count ?? 0 })
                let willKeepShare = sorted[0]
                sorted.dropFirst().forEach { willDeleteShare in
                    // 2. Move vessels to willKeep vesselShare
                    let vessels = (willDeleteShare.raw_vessels?.copy() as? NSSet) ?? []
                    for vessel in vessels {
                        guard let vessel = vessel as? CD_ReminderVessel else { continue }
                        willDeleteShare.removeFromRaw_vessels(vessel)
                        willKeepShare.addToRaw_vessels(vessel)
                    }
                    // 3. Delete all shares other than oldest one
                    context.delete(willDeleteShare)
                }
                // 4. Save
                try context.save()
                // 5. Mark the data as dirty so everything syncs
                UserDefaults.standard.didRunWithoutCloudSync = true
                "2+ VesselShares present, but was able to clean.".log(as: .warning)
                return .success(willKeepShare)
            }
        } catch {
            assertionFailure(String(describing: error))
            error.log(as: .error)
            return .failure(.maintenanceError)
        }
    }

    fileprivate func maintenance_fixDates() -> Result<Void, DatumError> {

        let context = self.container.viewContext
        let fetchRequest = CD_Base.requestBase
        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "%K == nil", #keyPath(CD_Base.raw_dateModified)),
            NSPredicate(format: "%K == nil", #keyPath(CD_Base.raw_dateCreated))
        ])

        do {
            let fetchResult = try context.fetch(fetchRequest)
            let count = fetchResult.count
            guard count > 0 else { return .success(()) }
            let now = Date()
            fetchResult.forEach {
                if $0.raw_dateCreated == nil {
                    let message = "DateCreated missing: \($0)"
                    assertionFailure(message)
                    message.log(as: .error)
                    $0.raw_dateCreated = now
                }
                if $0.raw_dateModified == nil {
                    let message = "DateModified missing: \($0)"
                    assertionFailure(message)
                    message.log(as: .error)
                    $0.raw_dateModified = now
                }
            }
            try context.save()
            "NIL Dates found: \(count)".log(as: .error)
            return .success(())
        } catch {
            assertionFailure(String(describing: error))
            error.log(as: .error)
            return .failure(.maintenanceError)
        }
    }

    fileprivate func maintenance_deleteOrphanedReminders() -> Result<Void, DatumError> {
        let context = self.container.viewContext
        let fetchRequest = CD_Reminder.request
        fetchRequest.predicate = NSPredicate(format: "%K == nil", #keyPath(CD_Reminder.raw_vessel))
        do {
            let fetchResult = try context.fetch(fetchRequest)
            let count = fetchResult.count
            guard count > 0 else { return .success(()) }
            fetchResult.forEach { context.delete($0) }
            try context.save()
            "Orphaned Reminders Deleted: \(count)".log(as: .error)
            return .success(())
        } catch {
            assertionFailure(String(describing: error))
            error.log(as: .error)
            return .failure(.maintenanceError)
        }
    }

    fileprivate func maintenance_fixOrphanedVessels(share: CD_VesselShare) -> Result<Void, DatumError> {
        let context = self.container.viewContext
        let fetchRequest = CD_ReminderVessel.request
        fetchRequest.predicate = NSPredicate(format: "%K == nil", #keyPath(CD_ReminderVessel.raw_share))
        do {
            let fetchResult = try context.fetch(fetchRequest)
            let count = fetchResult.count
            guard count > 0 else { return .success(()) }
            guard context === share.managedObjectContext else { return .failure(.maintenanceError) }
            fetchResult.forEach { share.addToRaw_vessels($0) }
            try context.save()
            "Orphaned ReminderVessels Found: \(count)".log(as: .error)
            return .success(())
        } catch {
            assertionFailure(String(describing: error))
            error.log(as: .error)
            return .failure(.maintenanceError)
        }
    }
}

// MARK: First Launch

extension CD_BasicController {

    private static let sampleDB1URL = Bundle.main.url(forResource: "StarterData", withExtension: "sqlite")
    private static let sampleDB2URL = Bundle.main.url(forResource: "StarterData", withExtension: "sqlite-wal")

    internal static let storeDirectoryURL: URL = {
        let fm = FileManager.default
        if let appGroup = fm.containerURL(forSecurityApplicationGroupIdentifier: "group.com.saturdayapps.WaterMe") {
            return appGroup
                .appendingPathComponent("Library", isDirectory: true)
                .appendingPathComponent("Application Support", isDirectory: true)
                .appendingPathComponent("WaterMe", isDirectory: true)
                .appendingPathComponent("CoreData", isDirectory: true)
        } else {
            "App group container could not be found".log(as: .emergency)
            return fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                .appendingPathComponent("WaterMe", isDirectory: true)
                .appendingPathComponent("CoreData", isDirectory: true)
        }
    }()

    private static let dbFileURL1: URL = {
        return CD_BasicController
            .storeDirectoryURL
            .appendingPathComponent("WaterMe.sqlite", isDirectory: false)
    }()

    private static let dbFileURL2: URL = {
        return CD_BasicController
            .storeDirectoryURL
            .appendingPathComponent("WaterMe.sqlite-wal", isDirectory: false)
    }()

    internal class var storeExists: Bool {
        let fm = FileManager.default
        let exists = fm.fileExists(atPath: self.dbFileURL1.path)
        return exists
    }

    private class func copySampleDBIfNeeded() {
        guard
            !RLM_BasicController.storeExists,
            !self.storeExists
        else { return }
        guard
            let sampleDB1URL = self.sampleDB1URL,
            let sampleDB2URL = self.sampleDB2URL
        else {
            let e = "Unable to find sample DB files in bundle"
            e.log(as: .warning)
            return
        }
        let fm = FileManager.default
        try? fm.createDirectory(at: self.storeDirectoryURL,
                                withIntermediateDirectories: true,
                                attributes: nil)
        do {
            try fm.copyItem(at: sampleDB1URL, to: self.dbFileURL1)
            try fm.copyItem(at: sampleDB2URL, to: self.dbFileURL2)
        } catch {
            error.log()
            try? fm.removeItem(at: self.storeDirectoryURL)
        }
    }
}

private class WaterMe_PersistentContainer: NSPersistentContainer {
    override class func defaultDirectoryURL() -> URL {
        return CD_BasicController.storeDirectoryURL
    }
    deinit {
        Loggable.default?.verbose()
    }
}

@available(iOS 14.0, *)
private class WaterMe_PersistentSyncContainer: NSPersistentCloudKitContainer {
    override class func defaultDirectoryURL() -> URL {
        return CD_BasicController.storeDirectoryURL
    }
    deinit {
        Loggable.default?.verbose()
    }
}

extension NSManagedObjectContext {
    fileprivate func waterme_save() -> Result<Void, DatumError> {
        // debug only sanity checks
        assert(Thread.isMainThread)

        do {
            try self.save()
            return .success(())
        } catch let error as NSError {
            // doing this async stops the tableviews from crashing
            // TODO: Figure out how to remove this async
            DispatchQueue.main.async {
                // we need to rollback the context
                self.rollback()
            }
            error.log()
            return .failure(.writeError)
        }
    }
}
