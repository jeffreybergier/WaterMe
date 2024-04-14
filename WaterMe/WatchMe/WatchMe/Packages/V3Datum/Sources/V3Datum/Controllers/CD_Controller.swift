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

import Combine
import CoreData
import Umbrella
import V3Settings
import V3Model

internal class CD_Controller: ControllerProtocol {

    // MARK: Init
    
    // swiftlint:disable:next function_body_length
    public init(kind: ControllerKind) throws {
        // debug only sanity checks
        assert(Thread.isMainThread)

        guard let container = CD_Controller.container(kind: kind) else {
            throw Error.load
        }

        switch kind {
        case .local, .sync:
            type(of: self).copySampleDBIfNeeded()
        case .__testing_inMemory, .__testing_withClass:
            break // don't copy sameple DB when testing
        }

        let lock = DispatchSemaphore(value: 0)
        var error: Swift.Error?
        container.loadPersistentStores { _, _error in
            error = _error
            lock.signal()
        }
        lock.wait()

        guard error == nil else { throw error! }
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        if case .sync = kind, let container = container as? NSPersistentCloudKitContainer {
            let monitor = CDCloudKitSyncMonitor(container)
            self.syncMonitor = monitor
            self.syncProgress = monitor.progressBox
        } else {
            self.syncMonitor = nil
            self.syncProgress = .init(.init())
        }

        // Set properties
        self.kind = kind
        self.container = container

        if case .local = self.kind {
            UserDefaults.standard.didRunWithoutCloudSync = true
        }

        // Observe sync changes to perform maintenance
        self.maintenance_syncToken = self.syncProgress.objectWillChange
            .debounce(for: .seconds(3), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard
                    let self = self,
                    self.syncProgress.value.progress.fractionCompleted == 1
                else { return }
                NSLog("Performing post syncing maintenance")
                // Perform maintenance and log any errors
                let error = self.maintenance_fixDates()
                    .reduce(self.maintenance_deleteOrphanedReminders)
                    .reduce(self.maintenance_oneTrueVesselShare)
                    .reduce(self.maintenance_fixOrphanedVessels(share:))
                    .reduce(self.maintenance_massageAllEntries)
                    .error
                guard let e = error else { return }
                NSLog(String(describing: e))
            }

        //
        // DEBUG ONLY
        // initialize the CloudKit schema
        // only do this once per change to CD MOM
        //
        #if DEBUG
        guard let container = container as? NSPersistentCloudKitContainer else { return }
        let configureCKSchema = false
        if configureCKSchema {
            // swiftlint:disable:next force_try
            try! container.initializeCloudKitSchema(options: [.printSchema])
            fatalError("Cannot continue while using: initializeCloudKitSchema")
        }
        #endif
    }

    private var maintenance_syncToken: AnyCancellable?

    // MARK: Protocol Conformance
    
    internal let container: NSPersistentContainer
    internal let kind: ControllerKind
    private  let syncMonitor: CDCloudKitSyncMonitor?
    internal let syncProgress: ContinousProgress.Environment
    internal var context: NSManagedObjectContext {
        return self.container.viewContext
    }
    
    // MARK: Create
    
    internal func createVessel() -> Result<Vessel.Selection.Element, Error> {
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
        vessel.raw_share = vesselShare

        // save
        return context.waterme_save().map {
            Vessel.Identifier(vessel.objectID)
        }
    }
    
    internal func createReminder(in vessel: Vessel.Identifier) -> Result<Reminder.Selection.Element, Error> {
        let context = self.container.viewContext
        return __genericSearch(matching: vessel.id).flatMap
        { (vessel: CD_ReminderVessel) -> Result<Reminder.Identifier, Error> in
            // debug only sanity checks
            assert(Thread.isMainThread)
            assert(context === vessel.managedObjectContext!)

            let newReminder = CD_Reminder(context: context)
            context.insert(newReminder)
            // core data hooks up the inverse relationship
            newReminder.raw_vessel = vessel
            return context.waterme_save()
                .map { Reminder.Identifier(newReminder.objectID) }
        }
    }

    internal func appendNewPerformToReminders(with ids: Reminder.Selection) -> Result<Void, Error> {
        // debug only sanity checks
        assert(Thread.isMainThread)

        let results: [Result<CD_Reminder, Error>] = ids.map{ $0.id }.map(__genericSearch(matching:))
        let reminders = results.compactMap { try? $0.get() }
        guard reminders.count == ids.count else { return .failure(.objectMissing) }

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

    internal func delete(_ ids: Vessel.Selection) -> Result<Void, Error> {
        assert(Thread.isMainThread)
        let vessels: [CD_ReminderVessel] = ids.compactMap { __genericSearch(matching: $0.rawValue).value }
        guard vessels.count == ids.count else { return .failure(.objectMissing) }
        let context = self.container.viewContext
        assert(vessels.reduce(true) {
            guard $0 else { return false }
            return $1.managedObjectContext === context
        })
        vessels.forEach(context.delete(_:))
        return context.waterme_save()
    }

    internal func delete(_ ids: Reminder.Selection) -> Result<Void, Error> {
        // Precondition
        assert(Thread.isMainThread)
        let reminders: [CD_Reminder] = ids.compactMap { __genericSearch(matching: $0.rawValue).value }
        guard reminders.count == ids.count else { return .failure(.objectMissing) }
        let context = self.container.viewContext
        assert(reminders.reduce(true) {
            guard $0 else { return $0 }
            return $1.managedObjectContext === context
        })
        
        // Logic to see if there were any issues when trying to delete
        let result: Result<Void, Error> = reminders.reduce(.success(()))
        { prev, reminder in
            guard case .success = prev else { return prev }
            assert(context === reminder.managedObjectContext)
            // Verify this reminder belongs to a vessel.
            guard let vessel = reminder.raw_vessel else {
                context.delete(reminder)
                return .success(())
            }
            // Verify this is not the last reminder for a vessel
            let reminderCount = vessel.raw_reminders?.count ?? 0
            guard reminderCount >= 2 else {
                return .failure(.cannotDeleteLastReminder)
            }
            context.delete(reminder)
            return .success(())
        }
        
        // If no issues, save. If there are issues, rollback
        switch result {
        case .success:
            return context.waterme_save()
        case .failure:
            context.rollback()
            return result
        }
    }

    // MARK: Search

    // swiftlint:disable:next function_body_length
    private func __genericSearch<T: CD_Base>(matching uuid: String) -> Result<T, Error> {
        let coordinator = self.container.persistentStoreCoordinator
        let context = self.container.viewContext

        // debug only sanity checks
        assert(Thread.isMainThread)

        do {
            if uuid.starts(with: "x-coredata://"), let url = URL(string: uuid) {
                // Core Data reference
                guard let id = coordinator.managedObjectID(forURIRepresentation: url)
                    else { return .failure(.objectMissing) }
                let _object = try context.existingObject(with: id)
                // if the object is the wrong type, log as an error
                guard let object = _object as? T else { return .failure(.objectMissing) }
                return .success(object)
            } else if UUID(uuidString: uuid) != nil {
                // Migrated Legacy Realm Reference
                let req = NSFetchRequest<NSFetchRequestResult>(entityName: T.entityName)
                let kp = #keyPath(CD_Base.raw_migrated.raw_realmIdentifier)
                req.predicate = .init(format: "%K == %@", kp, uuid)
                let results = try context.fetch(req)
                let count = results.count
                // if we had no results, return object deleted
                guard count > 0 else { return .failure(.objectMissing) }
                // if we had more than 1 result, just log this as an error
                if count > 1 {
                    let e = ("\(T.self), id: \(uuid), count: \(count): "
                           + "There should only be 1 match")
                    assertionFailure(e)
                    NSLog(e)
                }
                // if the object is the wrong type, log this as an error
                let _object = results[0]
                guard let object = _object as? T else {
                    let e = "found: \(type(of: _object)) != expected: \(T.self))"
                    assertionFailure(e)
                    NSLog(e)
                    return .failure(.objectMissing)
                }
                return .success(object)
            } else {
                let e = "\(uuid): does not appear to be Core Data or Realm identifier"
                assertionFailure(e)
                NSLog(e)
                return .failure(.objectMissing)
            }
        } catch {
            return .failure(.objectMissing)
        }
    }

    // MARK: Internal for Property Wrappers

    internal func cd_updateOpt(_ cd: CD_Reminder?, with newValue: Reminder?) -> Result<Void, Swift.Error> {
        // TODO: If nil should I return an error?
        self.cd_update(cd!, with: newValue!)
    }

    internal func cd_update(_ cd: CD_Reminder, with newValue: Reminder) -> Result<Void, Swift.Error> {
        cd.raw_kindString        = newValue.kind.rawValue
        cd.raw_descriptionString = newValue.kindDescription
        cd.raw_interval          = Int32(newValue.interval)
        cd.raw_isEnabled         = newValue.isEnabled
        cd.raw_note              = newValue.note
        cd.updateDates()
        return self.container.viewContext.NEW_waterme_save()
    }

    internal func cd_updateOpt(_ cd: CD_ReminderVessel?, with newValue: Vessel?) -> Result<Void, Swift.Error> {
        self.cd_update(cd!, with: newValue!)
    }

    internal func cd_update(_ cd: CD_ReminderVessel, with newValue: Vessel) -> Result<Void, Swift.Error> {
        cd.raw_displayName     = newValue.displayName
        cd.raw_kindString      = newValue.kind.rawValue
        cd.raw_iconEmojiString = newValue.icon?.stringValue
        cd.raw_iconImageData   = newValue.icon?.dataValue
        return self.container.viewContext.NEW_waterme_save()
    }
    
    internal func cd_search(_ id: Share.Identifier) -> Result<CD_VesselShare, Error> {
        return __genericSearch(matching: id.rawValue)
    }
    
    internal func cd_search(_ id: Vessel.Identifier) -> Result<CD_ReminderVessel, Error> {
        return __genericSearch(matching: id.rawValue)
    }
    
    internal func cd_search(_ id: Reminder.Identifier) -> Result<CD_Reminder, Error> {
        return __genericSearch(matching: id.rawValue)
    }

    deinit {
        NSLog("DEINIT: CD_Controller")
    }
}

// MARK: Maintenance

extension CD_Controller {

    fileprivate func maintenance_massageAllEntries() -> Result<Void, Error> {
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
            NSLog(String(describing: error))
            return .failure(.maintenanceMassageAllEntries)
        }
    }

    // have to make 2 functions because of type issues in maintenance token code in INIT
    fileprivate func maintenance_oneTrueVesselShare() -> Result<CD_VesselShare, Error> {
        return self.maintenance_oneTrueVesselShare(context: nil)
    }

    /* internal for migration only */
    internal func maintenance_oneTrueVesselShare(context: NSManagedObjectContext?) -> Result<CD_VesselShare, Error> {
        let context = context ?? self.container.viewContext
        do {
            // Clean up any errors caused by weird syncing
            // 1. Fetch all VesselShare objects
            let fetchRequest = CD_VesselShare.request
            let fetchResult = try context.fetch(fetchRequest)
            switch fetchResult.count {
            case 0:
                #if os(watchOS) && RELEASE
                // WatchOS should not create a vesselshare because watchOS
                // waits for syncing from iCloud.
                // RELEASE check added because when debugging, the DB needs
                // to work without syncing.
                return .failure(.maintenanceOneTrueVesselShare)
                #else
                let share = CD_VesselShare(context: context)
                context.insert(share)
                try context.save()
                NSLog("0 VesselShares present, but was able to create")
                return .success(share)
                #endif
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
                NSLog("2+ VesselShares present, but was able to clean.")
                return .success(willKeepShare)
            }
        } catch {
            assertionFailure(String(describing: error))
            NSLog(String(describing: error))
            return .failure(.maintenanceOneTrueVesselShare)
        }
    }

    fileprivate func maintenance_fixDates() -> Result<Void, Error> {

        let context = self.container.viewContext
        let fetchRequest = CD_Base.requestBase
        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "%K == nil", #keyPath(CD_Base.raw_dateModified)),
            NSPredicate(format: "%K == nil", #keyPath(CD_Base.raw_dateCreated)),
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
                    NSLog(message)
                    $0.raw_dateCreated = now
                }
                if $0.raw_dateModified == nil {
                    let message = "DateModified missing: \($0)"
                    assertionFailure(message)
                    NSLog(message)
                    $0.raw_dateModified = now
                }
            }
            try context.save()
            NSLog("NIL Dates found: \(count)")
            return .success(())
        } catch {
            let message = String(describing: error)
            assertionFailure(message)
            NSLog(message)
            return .failure(.maintenanceFixDates)
        }
    }

    fileprivate func maintenance_deleteOrphanedReminders() -> Result<Void, Error> {
        return .success(()) // skip this because a slow sync will cause data loss
        /*
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
            return .failure(.maintenanceDeleteOrphanedReminders)
        }
        */
    }

    fileprivate func maintenance_fixOrphanedVessels(share: CD_VesselShare) -> Result<Void, Error> {
        return .success(()) // skip this because a slow sync will cause data loss
        /*
        let context = self.container.viewContext
        let fetchRequest = CD_ReminderVessel.request
        fetchRequest.predicate = NSPredicate(format: "%K == nil", #keyPath(CD_ReminderVessel.raw_share))
        do {
            let fetchResult = try context.fetch(fetchRequest)
            let count = fetchResult.count
            guard count > 0 else { return .success(()) }
            guard context === share.managedObjectContext else { return .failure(.maintenanceContextMismatch) }
            fetchResult.forEach { share.addToRaw_vessels($0) }
            try context.save()
            "Orphaned ReminderVessels Found: \(count)".log(as: .error)
            return .success(())
        } catch {
            assertionFailure(String(describing: error))
            error.log(as: .error)
            return .failure(.maintenanceFixOrphanedVessels)
        }
        */
    }
}


// MARK: Custom storage

private class WaterMe_PersistentContainer: NSPersistentContainer {
    override class func defaultDirectoryURL() -> URL {
        return CD_Controller.storeDirectoryURL
    }
    deinit {
        NSLog("DEINIT: WaterMe_PersistentContainer")
    }
}

@available(iOS 14.0, *)
private class WaterMe_PersistentSyncContainer: NSPersistentCloudKitContainer {
    override class func defaultDirectoryURL() -> URL {
        return CD_Controller.storeDirectoryURL
    }
    deinit {
        NSLog("DEINIT: WaterMe_PersistentSyncContainer")
    }
}

extension CD_Controller {
    private class func container(kind: ControllerKind) -> NSPersistentContainer? {
        // debug only sanity checks
        assert(Thread.isMainThread)
        guard
            let url = Bundle.module.url(forResource: "WaterMe", withExtension: "momd"),
            let mom = NSManagedObjectModel(contentsOf: url)
        else {
            NSLog("Unable to load MOM from application bundle")
            return nil
        }
        switch kind {
        case .sync:
            return WaterMe_PersistentSyncContainer(name: "WaterMe", managedObjectModel: mom)
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
}

// MARK: First Launch

extension CD_Controller {
    
    fileprivate static let storeDirectoryURL: URL = {
        let fm = FileManager.default
        if let appGroup = fm.containerURL(forSecurityApplicationGroupIdentifier: "group.com.saturdayapps.WaterMe") {
            return appGroup
                .appendingPathComponent("Library", isDirectory: true)
                .appendingPathComponent("Application Support", isDirectory: true)
                .appendingPathComponent("WaterMe", isDirectory: true)
                .appendingPathComponent("CoreData", isDirectory: true)
        } else {
            NSLog("App group container could not be found")
            return fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                .appendingPathComponent("WaterMe", isDirectory: true)
                .appendingPathComponent("CoreData", isDirectory: true)
        }
    }()
    
    fileprivate static var storeExists: Bool {
        let fm = FileManager.default
        let exists = fm.fileExists(atPath: self.dbFileURL1.path)
        return exists
    }

    private static let sampleDB1URL = Bundle.module.url(forResource: "SampleDB", withExtension: "sqlite")
    private static let sampleDB2URL = Bundle.module.url(forResource: "SampleDB", withExtension: "sqlite-wal")

    private static let dbFileURL1: URL = {
        return CD_Controller
            .storeDirectoryURL
            .appendingPathComponent("WaterMe.sqlite", isDirectory: false)
    }()

    private static let dbFileURL2: URL = {
        return CD_Controller
            .storeDirectoryURL
            .appendingPathComponent("WaterMe.sqlite-wal", isDirectory: false)
    }()

    private static let RLM_legacyStoreDirectoryURL: URL = {
        return FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("WaterMe", isDirectory: true)
            .appendingPathComponent("Free", isDirectory: true)
    }()

    private static let RLM_legacyRealmFile: URL = {
        return RLM_legacyStoreDirectoryURL
            .appendingPathComponent("Realm.realm", isDirectory: false)
    }()

    internal class var RLM_legacyStoreExists: Bool {
        let fm = FileManager.default
        let exists = fm.fileExists(atPath: self.RLM_legacyRealmFile.path)
        return exists
    }

    private class func copySampleDBIfNeeded() {
        #if os(watchOS)
        // WatchOS waits for iCloud sync, so it does not need the sample DB
        return
        #endif
        guard
            !self.RLM_legacyStoreExists,
            !self.storeExists
        else { return }
        guard
            let sampleDB1URL = self.sampleDB1URL,
            let sampleDB2URL = self.sampleDB2URL
        else {
            NSLog("Unable to find sample DB files in bundle")
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
            NSLog(String(describing: error))
            try? fm.removeItem(at: self.storeDirectoryURL)
        }
    }
}

// MARK: Context Save

extension NSManagedObjectContext {
    fileprivate func waterme_save() -> Result<Void, Error> {
        // debug only sanity checks
        assert(Thread.isMainThread)

        do {
            try self.save()
            return .success(())
        } catch let error as NSError {
            // doing this async stops the tableviews from crashing
            DispatchQueue.main.async {
                // we need to rollback the context
                self.rollback()
            }
            NSLog(String(describing: error))
            return .failure(.write)
        }
    }
    
    // TODO: Switch all saving to this function
    fileprivate func NEW_waterme_save() -> Result<Void, Swift.Error> {
        // debug only sanity checks
        assert(Thread.isMainThread)

        do {
            try self.save()
            return .success(())
        } catch let error {
            // doing this async stops the tableviews from crashing
            // TODO: Figure out how to remove this async
            DispatchQueue.main.async {
                // we need to rollback the context
                self.rollback()
            }
            NSLog(String(describing: error))
            return .failure(error)
        }
    }
}
