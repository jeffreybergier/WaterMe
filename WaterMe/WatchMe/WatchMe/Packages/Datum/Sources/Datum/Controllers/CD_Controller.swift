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

public enum ControllerKind: RawRepresentable {

    case local
    case sync
    case __testing_inMemory
    case __testing_withClass(NSPersistentContainer.Type)

    public var rawValue: Bool {
        switch self {
        case .local:
            return false
        case .sync:
            return true
        case .__testing_inMemory, .__testing_withClass:
            fatalError("RawValue unsupported while testing")
        }
    }

    public init(rawValue: Bool) {
        self = rawValue ? .sync : .local
    }
}

public class CD_Controller: ObservableObject {
 
    private class func container(kind: ControllerKind) -> NSPersistentContainer? {
        // debug only sanity checks
        assert(Thread.isMainThread)

        
        guard
            let url = Bundle.module.url(forResource: "WaterMe", withExtension: "momd"),
            let mom = NSManagedObjectModel(contentsOf: url)
        else {
            "Unable to load MOM from application bundle" //.log(as: .emergency)
            return nil
        }

        switch kind {
        case .sync:
            fatalError()
//            if #available(iOS 14.0, *) {
//                return WaterMe_PersistentSyncContainer(name: "WaterMe", managedObjectModel: mom)
//            } else {
//                let message = "Attempted to load Sync container from iOS 13 or lower."
//                message.log(as: .info)
//                fallthrough
//            }
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
    public init(kind: ControllerKind) throws {
        // debug only sanity checks
        assert(Thread.isMainThread)

        guard let container = CD_Controller.container(kind: kind)
            else { fatalError() } //DatumError.load }

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

//        switch kind {
//        case .local, .sync:
//            guard #available(iOS 14.0, *), container is NSPersistentCloudKitContainer
//            else { self._syncProgress = nil; break; }
//            self._syncProgress = AnyContinousProgress(CloudKitContainerContinuousProgress(container))
//        case .__testing_inMemory, .__testing_withClass:
//            self._syncProgress = nil
//        }

        // Set properties
        self.kind = kind
        self.container = container

        // Configure maintenance monitor
//        self.maintenance_changeToken = self.maintenance_changeMonitor()
//        if case .local = self.kind {
//            UserDefaults.standard.didRunWithoutCloudSync = true
//        }

        // Observe sync changes to perform maintenance
//        if #available(iOS 14.0, *) {
//            self.maintenance_syncToken = self.syncProgress?.objectWillChange
//                .debounce(for: .seconds(3), scheduler: RunLoop.main)
//                .sink { [weak self] _ in
//                    guard
//                        let self = self,
//                        self.syncProgress?.progress.fractionCompleted == 1
//                    else { return }
//                    "Performing post syncing maintenance".log(as: .debug)
//                    // Perform maintenance and log any errors
//                    self.maintenance_fixDates()
//                        .reduce(self.maintenance_deleteOrphanedReminders)
//                        .reduce(self.maintenance_oneTrueVesselShare)
//                        .reduce(self.maintenance_fixOrphanedVessels(share:))
//                        .reduce(self.maintenance_massageAllEntries)
//                        .error?.log()
//                }
//        }

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
    
    internal let container: NSPersistentContainer
    public let kind: ControllerKind
    public var __ENVONLY__managedObjectContext: NSManagedObjectContext {
        return self.container.viewContext
    }
}

// MARK: First Launch

extension CD_Controller {

    private static let sampleDB1URL = Bundle.module.url(forResource: "SampleDB", withExtension: "sqlite")
    private static let sampleDB2URL = Bundle.module.url(forResource: "SampleDB", withExtension: "sqlite-wal")

    internal static let storeDirectoryURL: URL = {
        let fm = FileManager.default
        /*
        if let appGroup = fm.containerURL(forSecurityApplicationGroupIdentifier: "group.com.saturdayapps.WaterMe") {
            return appGroup
                .appendingPathComponent("Library", isDirectory: true)
                .appendingPathComponent("Application Support", isDirectory: true)
                .appendingPathComponent("WaterMe", isDirectory: true)
                .appendingPathComponent("CoreData", isDirectory: true)
        } else {
         */
            "App group container could not be found"// .log(as: .emergency)
            let url = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                .appendingPathComponent("WaterMe", isDirectory: true)
                .appendingPathComponent("CoreData", isDirectory: true)
        return url
        // file:///Users/jeffberg/Library/Developer/CoreSimulator/Devices/AC661100-4106-4564-80B9-2F1DEB8DB4C5/data/Containers/Data/PluginKitPlugin/025C0612-D021-4DAF-A2C8-0728F236591E/Library/Application%20Support/WaterMe.sqlite)
//        }
    }()

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

    internal class var storeExists: Bool {
        let fm = FileManager.default
        let exists = fm.fileExists(atPath: self.dbFileURL1.path)
        return exists
    }
    
    internal class var RLM_legacyStoreExists: Bool {
        let fm = FileManager.default
        let exists = fm.fileExists(atPath: self.RLM_legacyRealmFile.path)
        return exists
    }

    private class func copySampleDBIfNeeded() {
        guard
            !self.RLM_legacyStoreExists,
            !self.storeExists
        else { return }
        guard
            let sampleDB1URL = self.sampleDB1URL,
            let sampleDB2URL = self.sampleDB2URL
        else {
            let e = "Unable to find sample DB files in bundle"
            e// .log(as: .warning)
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
            error// .log()
            try? fm.removeItem(at: self.storeDirectoryURL)
        }
    }
}

private class WaterMe_PersistentContainer: NSPersistentContainer {
    override class func defaultDirectoryURL() -> URL {
        return CD_Controller.storeDirectoryURL
    }
    deinit {
        // Loggable.default?.verbose()
    }
}

@available(iOS 14.0, *)
private class WaterMe_PersistentSyncContainer: NSPersistentCloudKitContainer {
    override class func defaultDirectoryURL() -> URL {
        return CD_Controller.storeDirectoryURL
    }
    deinit {
        // Loggable.default?.verbose()
    }
}
