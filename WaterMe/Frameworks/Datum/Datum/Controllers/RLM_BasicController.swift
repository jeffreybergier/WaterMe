//
//  BasicController.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/18/17.
//  Copyright © 2017 Saturday Apps.
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

import RealmSwift
import UIKit
import Calculate

extension Realm {
    internal func waterMe_commitWrite() -> Result<Void, DatumError> {
        do {
            try self.commitWrite()
            return .success(())
        } catch {
            error.log()
            return .failure(.writeError)
        }
    }
}

internal class RLM_BasicController: BasicController {    

    // MARK: Observation Closures

    internal var remindersDeleted: ((Set<ReminderValue>) -> Void)?
    internal var reminderVesselsDeleted: ((Set<ReminderVesselValue>) -> Void)?
    internal var userDidPerformReminder: ((Set<ReminderValue>) -> Void)?
    
    // MARK: Initialization

    internal let kind: ControllerKind
    @available(iOS 14.0, *)
    internal var syncProgress: AnyContinousProgress<GenericInitializationError, CloudKitSyncError>? {
        return nil
    }
    private let config: Realm.Configuration
    #if DEBUG
    // Reference is needed for using in-memory data stores
    private var realmReference: Realm?
    #endif
    // Internal only for testing. Should be private.
    internal var realm: Result<Realm, DatumError> {
        do {
            let realm = try Realm(configuration: self.config)
            #if DEBUG
            if self.realmReference == nil {
                self.realmReference = realm
            }
            #endif
            return .success(realm)
        } catch {
            error.log()
            return .failure(.loadError)
        }
    }

    internal init(kind: ControllerKind) throws {
        self.kind = kind
        var realmConfig = Realm.Configuration()
        realmConfig.schemaVersion = 14
        realmConfig.objectTypes = [RLM_ReminderVessel.self, RLM_Reminder.self, RLM_ReminderPerform.self]
        try type(of: self).createLocalRealmDirectoryIfNeeded()
        try type(of: self).copyRealmFromBundleIfNeeded()
        switch kind {
        case .local:
            realmConfig.fileURL = type(of: self).localRealmFile
        case .__testing_inMemory, .__testing_withClass:
            realmConfig.inMemoryIdentifier = String(Int.random(in: 100_000...1_000_000))
        case .sync: /*(let user)*/
            // let url = user.realmURL(withAppName: "WaterMeBasic")
            fatalError("Syncing Realms are Not Implemented for WaterMe Yet")
        }
        self.config = realmConfig
    }
    
    // MARK: WaterMeClient API

    internal func allVessels(sorted: ReminderVesselSortOrder,
                             ascending: Bool)
                             -> Result<AnyCollectionQuery<ReminderVessel, Int>, DatumError>
    {
        return self.realm.map() { realm in
            let collection = realm.objects(RLM_ReminderVessel.self)
                                  .sorted(byKeyPath: RLM_ReminderVessel.keyPath(for: sorted),
                                          ascending: ascending)
            return AnyCollectionQuery(
                RLM_ReminderVesselQuery(
                    AnyRealmCollection(collection)
                )
            )
        }
    }

    internal func enabledReminders(sorted: ReminderSortOrder = .nextPerformDate,
                                   ascending: Bool = true)
                                   -> Result<AnyCollectionQuery<Reminder, Int>, DatumError>
    {
        return self.realm.map {
            AnyCollectionQuery(
                RLM_ReminderQuery(
                    AnyRealmCollection($0.objects(RLM_Reminder.self)
                        .sorted(byKeyPath: RLM_Reminder.keyPath(for: sorted),
                                ascending: ascending)
                    )
                )
            )
        }
    }

    internal func groupedReminders() -> Result<AnyCollectionQuery<Reminder, IndexPath>, DatumError> {
        var failure: DatumError?
        let _queries = ReminderSection.__realmCases.compactMap
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
        return self.realm.map() { realm in
            let range = section.dateInterval
            let sortKeyPath = RLM_Reminder.keyPath(for: sorted)
            let andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: #keyPath(RLM_Reminder.nextPerformDate)),
                                      rightExpression: NSExpression(forConstantValue: range.start),
                                      modifier: .direct,
                                      type: .greaterThanOrEqualTo),
                NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: #keyPath(RLM_Reminder.nextPerformDate)),
                                      rightExpression: NSExpression(forConstantValue: range.end),
                                      modifier: .direct,
                                      type: .lessThan)
                ])
            if case .late = section {
                let nilCheck = NSComparisonPredicate(
                    leftExpression: NSExpression(forKeyPath:#keyPath(RLM_Reminder.nextPerformDate)),
                    rightExpression: NSExpression(forConstantValue: nil),
                    modifier: .direct,
                    type: .equalTo
                )
                let orPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [nilCheck, andPredicate])
                let collection = realm.objects(RLM_Reminder.self).filter(orPredicate).sorted(byKeyPath: sortKeyPath, ascending: ascending)
                return AnyCollectionQuery(RLM_ReminderQuery(AnyRealmCollection(collection)))
            } else {
                let collection = realm.objects(RLM_Reminder.self).filter(andPredicate).sorted(byKeyPath: sortKeyPath, ascending: ascending)
                return AnyCollectionQuery(RLM_ReminderQuery(AnyRealmCollection(collection)))
            }
        }
    }

    internal func appendNewPerformToReminders(with identifiers: [Identifier]) -> Result<Void, DatumError> {
        let reminders = self.reminders(matching: identifiers)
        let result = reminders.flatMap({ self.appendNewPerform(to: $0) })
        if case .success = result, case .success(let reminders) = reminders {
            self.userDidPerformReminder?(Set(reminders.map { ReminderValue(reminder: $0) }))
        }
        return result
    }

    internal func reminderVessel(matching identifier: Identifier) -> Result<ReminderVessel, DatumError> {
        return self.realm.flatMap() { realm -> Result<ReminderVessel, DatumError> in
            guard let reminder = realm.object(ofType: RLM_ReminderVessel.self, forPrimaryKey: identifier.uuid)
            else { return .failure(.objectDeleted) }
            return .success(RLM_ReminderVesselWrapper(reminder))
        }
    }

    internal func reminder(matching identifier: Identifier) -> Result<Reminder, DatumError> {
        return self.realm.flatMap() { realm -> Result<Reminder, DatumError> in
            guard let reminder = realm.object(ofType: RLM_Reminder.self, forPrimaryKey: identifier.uuid)
            else { return .failure(.objectDeleted) }
            return .success(RLM_ReminderWrapper(reminder))
        }
    }

    internal func reminders(matching identifiers: [Identifier]) -> Result<[RLM_Reminder], DatumError> {
        return self.realm.map() { realm in
            return identifiers.compactMap({ realm.object(ofType: RLM_Reminder.self, forPrimaryKey: $0.uuid) })
        }
    }

    internal func appendNewPerform(to reminders: [RLM_Reminder]) -> Result<Void, DatumError> {
        return self.realm.flatMap() { realm in
            realm.beginWrite()
            for reminder in reminders {
                // append the perform
                let newPerform = RLM_ReminderPerform()
                reminder.performed.append(newPerform)
                reminder.recalculateNextPerformDate(comparisonPerform: newPerform)
                // perform bloops to force notification firing
                reminder.vessel?.bloop = !(reminder.vessel?.bloop ?? true)
            }
            return realm.waterMe_commitWrite()
        }
    }
    
    internal func newReminder(for vessel: ReminderVessel) -> Result<Reminder, DatumError> {
        let vessel = (vessel as! RLM_ReminderVesselWrapper).wrappedObject
        return self.realm.flatMap() { realm in
            let reminder = RLM_Reminder()
            realm.beginWrite()
            realm.add(reminder)
            vessel.reminders.append(reminder)
            return realm.waterMe_commitWrite().map({ RLM_ReminderWrapper(reminder) })
        }
    }
    
    internal func newReminderVessel(displayName: String? = nil,
                                    icon: ReminderVesselIcon? = nil)
                                    -> Result<ReminderVessel, DatumError>
    {
        return self.realm.flatMap() { realm in
            let v = RLM_ReminderVessel()
            if let displayName = displayName?.nonEmptyString { // make sure the string is not empty
                v.displayName = displayName
            }
            if let icon = icon {
                v.icon = icon
            }
            // enforce at least one reminder rule
            let reminder = RLM_Reminder()
            v.reminders.append(reminder)
            
            realm.beginWrite()
            realm.add(v)
            return realm.waterMe_commitWrite().map({ RLM_ReminderVesselWrapper(v) })
        }
    }
    
    internal func update(displayName: String? = nil,
                         icon: ReminderVesselIcon? = nil,
                         in vessel: ReminderVessel) -> Result<Void, DatumError>
    {
        let vessel = (vessel as! RLM_ReminderVesselWrapper).wrappedObject
        guard vessel.isInvalidated == false else { return .failure(.objectDeleted) }
        return self.realm.flatMap() { realm in
            realm.beginWrite()
            if let displayName = displayName {
                // make sure the string is not empty. If it is empty, set it to NIL
                vessel.displayName = displayName.nonEmptyString
            }
            if let icon = icon {
                vessel.icon = icon
                if vessel.icon == nil {
                    // something went wrong. We need to close the realm and present an error
                    _ = realm.waterMe_commitWrite()
                    return .failure(.imageCouldntBeCompressedEnough)
                }
            }
            // trigger the bloop so notifications fire for the reminder table view
            for reminder in vessel.reminders {
                reminder.bloop = !reminder.bloop
                for perform in reminder.performed {
                    perform.bloop = !perform.bloop
                }
            }
            return realm.waterMe_commitWrite()
        }
    }
    
    internal func update(kind: ReminderKind? = nil,
                         interval: Int? = nil,
                         isEnabled: Bool? = nil,
                         note: String? = nil,
                         in reminder: Reminder) -> Result<Void, DatumError>
    {
        let reminder = (reminder as! RLM_ReminderWrapper).wrappedObject
        guard reminder.isInvalidated == false else { return .failure(.objectDeleted) }
        return self.realm.flatMap() { realm in
            realm.beginWrite()
            if let kind = kind {
                reminder.kind = kind
            }
            if let interval = interval {
                reminder.interval = interval
                reminder.recalculateNextPerformDate()
            }
            if let isEnabled = isEnabled, isEnabled == false {
                realm.cancelWrite()
                return .failure(.realmIsEnabledFalseUnsupported)
            }
            if let note = note {
                // make sure the string is not empty. If it is empty, set it to blank string
                reminder.note = note.nonEmptyString
            }
            // trigger bloops so notifications fire
            reminder.vessel?.bloop = !(reminder.vessel?.bloop ?? true)
            for perform in reminder.performed {
                perform.bloop = !perform.bloop
            }
            return realm.waterMe_commitWrite()
        }
    }
        
    internal func delete(vessel: ReminderVessel) -> Result<Void, DatumError> {
        let vessel = (vessel as! RLM_ReminderVesselWrapper).wrappedObject
        let reminderValues = Set(vessel.reminders.map({ ReminderValue(reminder: $0) }))
        let vesselValue = ReminderVesselValue(reminderVessel: vessel)
        let result: Result<Void, DatumError> = self.realm.flatMap() { realm in
            realm.beginWrite()
            self.delete(vessel: vessel, inOpenRealm: realm)
            return realm.waterMe_commitWrite()
        }
        if case .success = result {
            self.remindersDeleted?(reminderValues)
            self.reminderVesselsDeleted?([vesselValue])
        }
        return result
    }
    
    private func delete(vessel: RLM_ReminderVessel, inOpenRealm realm: Realm) {
        for reminder in vessel.reminders {
            self.delete(reminder: reminder, inOpenRealm: realm)
        }
        realm.delete(vessel)
    }
        
    internal func delete(reminder: Reminder) -> Result<Void, DatumError> {
        let reminder = (reminder as! RLM_ReminderWrapper).wrappedObject
        if let vessel = reminder.vessel, vessel.reminders.count <= 1 {
            return .failure(.unableToDeleteLastReminder) 
        }
        let reminderValue = ReminderValue(reminder: reminder)
        let result: Result<Void, DatumError> = self.realm.flatMap() { realm in
            realm.beginWrite()
            self.delete(reminder: reminder, inOpenRealm: realm)
            return realm.waterMe_commitWrite()
        }
        if case .success = result {
            self.remindersDeleted?([reminderValue])
        }
        return result
    }
    
    private func delete(reminder: RLM_Reminder, inOpenRealm realm: Realm) {
        for perform in reminder.performed {
            realm.delete(perform)
        }
        realm.delete(reminder)
    }
}

extension RLM_BasicController {
    internal static let storeDirectoryURL: URL = {
        return FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("WaterMe", isDirectory: true)
            .appendingPathComponent("Free", isDirectory: true)
    }()

    internal class var storeExists: Bool {
        let fm = FileManager.default
        let exists = fm.fileExists(atPath: self.localRealmFile.path)
        return exists
    }

    private static let localRealmFile: URL = {
        return RLM_BasicController.storeDirectoryURL
            .appendingPathComponent("Realm.realm", isDirectory: false)
    }()

    private class func createLocalRealmDirectoryIfNeeded() throws {
        guard self.storeExists == false else { return }
        try FileManager.default.createDirectory(at: self.storeDirectoryURL,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
    }

    private class func copyRealmFromBundleIfNeeded() throws {
        guard
            self.storeExists == false,
            let bundleURL = Bundle.main.url(forResource: "StarterRealm", withExtension: "realm")
        else { return }
        try FileManager.default.copyItem(at: bundleURL, to: self.localRealmFile)
    }
}
