//
//  RealmToCoreDataMigrator.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/08/01.
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
import RealmSwift
import Calculate

internal class RealmToCoreDataMigrator: Migratable {

    private var source: RLM_BasicController?
    private let queue = DispatchQueue(label: "RealmToCoreDataMigrator", qos: .userInitiated)
    private let isTesting: Bool

    /// If `testingSource` is `NIL` class checks if local realm DB exists.
    /// If it does exist, then it creates a RLM_BasicController and initializes.
    /// If it does not exist it returns `NIL`
    /// If a `testingSource` is provided, then no checks are performed
    /// and the class always initializes.
    init?(testingSource: RLM_BasicController? = nil) {
        if let source = testingSource {
            self.source = source
            self.isTesting = true
            return
        }
        guard
            RLM_BasicController.storeExists,
            let source = try? RLM_BasicController(kind: .local)
        else { return nil }
        self.source = source
        self.isTesting = false
    }

    func skipMigration() -> MigratableResult {
        do {
            try FileManager.default.removeItem(at: RLM_BasicController.storeDirectoryURL)
            self.source = nil
            return .success(())
        } catch {
            return .failure(.finishError)
        }
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    @discardableResult func start(destination: BasicController,
                                  completion: @escaping (MigratableResult) -> Void) -> Progress
    {
        let progress = Progress(totalUnitCount: 0)
        progress.completedUnitCount = 0
        guard
            let source = self.source,
            let destination = destination as? CD_BasicController
        else {
            DispatchQueue.main.async { completion(.failure(.startError)) }
            return progress
        }

        // Get off main thread
        self.queue.async {
            // Get needed contexts and realms
            let context = destination.container.newBackgroundContext()
            context.performAndWait {
                guard
                    let realm = try? source.realm.get(),
                    let rhsShare = try? destination.maintenance_oneTrueVesselShare(context: context).get()
                else {
                    let e = MigratableError.startError
                    DispatchQueue.main.async { completion(.failure(e)) }
                    e.log()
                    return
                }
                
                // Get our Data to work with
                var srcVessels = Array(realm.objects(RLM_ReminderVessel.self))
                "Vessels to Migrate: \(srcVessels.count)".log(as: .debug)
                let totalUnitCount = Int64(srcVessels.count)
                progress.totalUnitCount = totalUnitCount
                var srcVessel: RLM_ReminderVessel! = srcVessels.popLast()
                
                // Loop over every vessel
                var completedUnitCount: Int64 = 0
                while srcVessel != nil {
                    autoreleasepool {
                        defer {
                            // if there are a lot of plants, I am worried about
                            // the collectionview crashing.
                            // Also, with a normal number of plants, this has
                            // almost no noticeable effect on speed.
                            if self.isTesting == false {
                                Thread.sleep(forTimeInterval: 0.2)
                            }
                            // Prepare for next loop
                            do {
                                try context.save()
                                completedUnitCount += 1
                                progress.completedUnitCount = completedUnitCount
                            } catch {
                                error.log()
                                context.rollback()
                            }
                            srcVessel = srcVessels.popLast()
                            "Vessels to Migrate: \(srcVessels.count)".log(as: .debug)
                        }
                        
                        // Vessel: Configure
                        let destVessel = CD_ReminderVessel(context: context)
                        destVessel.raw_migrated = CD_Migrated(context: context)
                        context.insert(destVessel)
                        
                        _ = {
                            // Vessel: Copy Data
                            destVessel.raw_share = rhsShare
                            destVessel.raw_displayName = srcVessel.displayName
                            destVessel.raw_iconImageData = srcVessel.iconImageData
                            destVessel.raw_iconEmojiString = srcVessel.iconEmojiString
                            destVessel.raw_kindString = srcVessel.kindString
                            destVessel.raw_migrated!.raw_realmIdentifier = srcVessel.uuid
                        }()
                        
                        for srcReminder in srcVessel.reminders {
                            // Reminder: Configure
                            let destReminder = CD_Reminder(context: context)
                            destReminder.raw_vessel = destVessel
                            destReminder.raw_migrated = CD_Migrated(context: context)
                            context.insert(destReminder)
                            
                            _ = {
                                // Reminder: Copy Data
                                destReminder.raw_interval = Int32(srcReminder.interval)
                                destReminder.raw_note = srcReminder.note
                                destReminder.raw_nextPerformDate = srcReminder.nextPerformDate
                                destReminder.raw_lastPerformDate = srcReminder.performed.last?.date
                                destReminder.raw_kindString = srcReminder.kindString
                                destReminder.raw_descriptionString = srcReminder.descriptionString
                                destReminder.raw_migrated!.raw_realmIdentifier = srcReminder.uuid
                            }()
                            
                            for srcPerform in srcReminder.performed {
                                // Perform: Configure
                                let destPerform = CD_ReminderPerform(context: context)
                                destPerform.raw_reminder = destReminder
                                context.insert(destPerform)
                                
                                _ = {
                                    // Perform: Copy Data
                                    destPerform.raw_date = srcPerform.date
                                }()
                            }
                        }
                    }
                }
                
                // check if we completed by comparing completion count
                var completed = completedUnitCount == totalUnitCount
                
                // do cleanup tasks only if we are not using unit tests
                if !TESTING {
                    if completed {
                        // Cleanup source, this HAS to work for migration to finish
                        do {
                            try FileManager.default.removeItem(at: RLM_BasicController.storeDirectoryURL)
                            "Migration Succeeded".log(as: .info)
                        } catch {
                            "Migration Error: Succeeded but failed to delete Realm DB: \(error)".log()
                            completed = false
                        }
                    } else {
                        // If we didn't complete, try to clean up the destination
                        // Don't clean up destination if source failed to delete
                        // Too risky, might lose data
                        for vessel in rhsShare.raw_vessels ?? [] {
                            guard let vessel = vessel as? NSManagedObject else { continue }
                            context.delete(vessel)
                        }
                        do {
                            try context.save()
                            "Migration Failed: Successfully cleaned up Core Data".log()
                        } catch {
                            "Migration Failed: Failed to clean up Core Data: \(error)".log()
                            context.rollback()
                        }
                    }
                }
                
                if completed {
                    DispatchQueue.main.async { completion(.success(())) }
                } else {
                    DispatchQueue.main.async { completion(.failure(.migrateError)) }
                }
            }
        }
        return progress
    }
}
