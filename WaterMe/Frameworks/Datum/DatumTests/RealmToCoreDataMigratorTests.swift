//
//  RealmToCoreDataMigratorTests.swift
//  DatumTests
//
//  Created by Jeffrey Bergier on 2020/08/02.
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

import XCTest
import CoreData
@testable import DatumL

class RealmToCoreDataMigratorBaseTests: XCTestCase {

    let source = try! RLM_BasicController(kind: .__testing_inMemory)
    let destination = try! CD_BasicController(kind: .__testing_inMemory)
    var token: ObservationToken?

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        let realmDir = RLM_BasicController.storeDirectoryURL
        let coreDataDir = CD_BasicController.storeDirectoryURL
        let fm = FileManager.default
        try? fm.removeItem(at: realmDir)
        try? fm.removeItem(at: coreDataDir)
    }
}

class RealmToCoreDataMigratorErrorTests: RealmToCoreDataMigratorBaseTests {

    func test_destinationIsNotCD() {
        let wait = XCTestExpectation()
        wait.expectedFulfillmentCount = 1
        let migrator = RealmToCoreDataMigrator(testingSource: self.source)!
        migrator.start(destination: self.source) { result in
            guard case .failure(let error) = result, case .startError = error else {
                XCTFail()
                return
            }
            wait.fulfill()
        }
        self.wait(for: [wait], timeout: 0.3)
    }
}

class RealmToCoreDataMigratorAccuracyTests: RealmToCoreDataMigratorBaseTests {

    override func setUpWithError() throws {
        try super.setUpWithError()

        let v_1 = try source.newReminderVessel(displayName: "One", icon: .emoji("1️⃣")).get()
        let v_2 = try source.newReminderVessel(displayName: "Two", icon: nil).get()
        let v_3 = try source.newReminderVessel(displayName: "Three", icon: .emoji("3️⃣")).get()

        let v_1_r_1 = try source.newReminder(for: v_1).get()
        let v_1_r_2 = try source.newReminder(for: v_1).get()
        let v_1_r_3 = try source.newReminder(for: v_1).get()

        try source.update(kind: .mist, interval: 1, note: nil, in: v_1_r_1).get()
        try source.update(kind: .fertilize, interval: 10, note: nil, in: v_1_r_2).get()
        try source.update(kind: .move(location: "Over There"), interval: 100, note: "This is a Note", in: v_1_r_3).get()

        let v_2_r_1 = try source.newReminder(for: v_2).get()
        let v_2_r_2 = try source.newReminder(for: v_2).get()
        let v_2_r_3 = try source.newReminder(for: v_2).get()

        try source.update(kind: .water, interval: -1, note: nil, in: v_2_r_1).get()
        try source.update(kind: .trim, interval: -10, note: nil, in: v_2_r_2).get()
        try source.update(kind: .other(description: nil), interval: -100, note: "This is a Note", in: v_2_r_3).get()

        let v_3_r_1 = try source.newReminder(for: v_3).get()
        let v_3_r_2 = try source.newReminder(for: v_3).get()
        let v_3_r_3 = try source.newReminder(for: v_3).get()

        try source.update(kind: .move(location: "One"), interval: 10000000, note: "One", in: v_3_r_1).get()
        try source.update(kind: .move(location: "Two"), interval: 100000000, note: "Two", in: v_3_r_2).get()
        try source.update(kind: .move(location: "Three"), interval: 1000000000, note: "Three", in: v_3_r_3).get()

        let allReminders = [v_1_r_1, v_1_r_2, v_1_r_3, v_2_r_1, v_2_r_2, v_2_r_3, v_3_r_1, v_3_r_2, v_3_r_3]
                           .map { Identifier(rawValue: $0.uuid) }
        try source.appendNewPerformToReminders(with: allReminders).get()
        try source.appendNewPerformToReminders(with: allReminders).get()
        try source.appendNewPerformToReminders(with: allReminders).get()
    }

    func test_migrationAccuracy() {
        let context = self.destination.container.viewContext
        let realm = try! self.source.realm.get()
        let srcPerforms: [Date] = realm.objects(RLM_ReminderPerform.self).map({ $0.date }).sorted(by: { $0 > $1 })
        let req_v = CD_ReminderVessel.request
        let req_r = CD_Reminder.request
        let req_p = CD_ReminderPerform.request
        XCTAssertEqual(try? context.fetch(req_v).count, 0)
        XCTAssertEqual(try? context.fetch(req_r).count, 0)
        XCTAssertEqual(try? context.fetch(req_p).count, 0)

        let migrator = RealmToCoreDataMigrator(testingSource: self.source)!
        let wait1 = XCTestExpectation()
        wait1.expectedFulfillmentCount = 1
        let progress = migrator.start(destination: self.destination) { result in
            wait1.fulfill()
            switch result {
            case .success:
                let vessels = try! context.fetch(req_v)
                let performs = try! context.fetch(req_p)
                XCTAssertEqual(vessels.count, 3)
                XCTAssertEqual(try? context.fetch(req_r).count, 12)
                XCTAssertEqual(performs.count, 27)

                let v_1 = vessels.filter({ $0.raw_displayName == "One" }).first!
                let v_2 = vessels.filter({ $0.raw_displayName == "Two" }).first!
                let v_3 = vessels.filter({ $0.raw_displayName == "Three" }).first!

                XCTAssertEqual(v_1.icon?.emoji, "1️⃣")
                XCTAssertNil(v_2.icon)
                XCTAssertEqual(v_3.icon?.emoji, "3️⃣")

                XCTAssertNotNil(v_1.raw_migrated!.raw_realmIdentifier)
                XCTAssertNotNil(v_2.raw_migrated!.raw_realmIdentifier)
                XCTAssertNotNil(v_3.raw_migrated!.raw_realmIdentifier)

                let v_1_r_1 = (v_1.raw_reminders as! Set<CD_Reminder>).filter({ $0.raw_interval == 1 }).first!
                let v_1_r_2 = (v_1.raw_reminders as! Set<CD_Reminder>).filter({ $0.raw_interval == 10 }).first!
                let v_1_r_3 = (v_1.raw_reminders as! Set<CD_Reminder>).filter({ $0.raw_interval == 100 }).first!

                XCTAssertEqual(v_1_r_1.kind, .mist)
                XCTAssertEqual(v_1_r_2.kind, .fertilize)
                XCTAssertEqual(v_1_r_3.kind, .move(location: "Over There"))

                XCTAssertNil(v_1_r_1.raw_note)
                XCTAssertNil(v_1_r_2.raw_note)
                XCTAssertEqual(v_1_r_3.raw_note, "This is a Note")

                XCTAssertNotNil(v_1_r_1.raw_migrated!.raw_realmIdentifier)
                XCTAssertNotNil(v_1_r_2.raw_migrated!.raw_realmIdentifier)
                XCTAssertNotNil(v_1_r_3.raw_migrated!.raw_realmIdentifier)

                let v_2_r_1 = (v_2.raw_reminders as! Set<CD_Reminder>).filter({ $0.raw_interval == -1 }).first!
                let v_2_r_2 = (v_2.raw_reminders as! Set<CD_Reminder>).filter({ $0.raw_interval == -10 }).first!
                let v_2_r_3 = (v_2.raw_reminders as! Set<CD_Reminder>).filter({ $0.raw_interval == -100 }).first!

                XCTAssertEqual(v_2_r_1.kind, .water)
                XCTAssertEqual(v_2_r_2.kind, .trim)
                XCTAssertEqual(v_2_r_3.kind, .other(description: nil))

                XCTAssertNil(v_2_r_1.raw_note)
                XCTAssertNil(v_2_r_2.raw_note)
                XCTAssertEqual(v_2_r_3.raw_note, "This is a Note")

                XCTAssertNotNil(v_2_r_1.raw_migrated!.raw_realmIdentifier)
                XCTAssertNotNil(v_2_r_2.raw_migrated!.raw_realmIdentifier)
                XCTAssertNotNil(v_2_r_3.raw_migrated!.raw_realmIdentifier)

                let v_3_r_1 = (v_3.raw_reminders as! Set<CD_Reminder>).filter({ $0.raw_interval == 10000000 }).first!
                let v_3_r_2 = (v_3.raw_reminders as! Set<CD_Reminder>).filter({ $0.raw_interval == 100000000 }).first!
                let v_3_r_3 = (v_3.raw_reminders as! Set<CD_Reminder>).filter({ $0.raw_interval == 1000000000 }).first!

                XCTAssertEqual(v_3_r_1.kind, .move(location: "One"))
                XCTAssertEqual(v_3_r_2.kind, .move(location: "Two"))
                XCTAssertEqual(v_3_r_3.kind, .move(location: "Three"))

                XCTAssertEqual(v_3_r_1.raw_note, "One")
                XCTAssertEqual(v_3_r_2.raw_note, "Two")
                XCTAssertEqual(v_3_r_3.raw_note, "Three")

                XCTAssertNotNil(v_3_r_1.raw_migrated!.raw_realmIdentifier)
                XCTAssertNotNil(v_3_r_2.raw_migrated!.raw_realmIdentifier)
                XCTAssertNotNil(v_3_r_3.raw_migrated!.raw_realmIdentifier)

                let allReminders = [v_1_r_1, v_1_r_2, v_1_r_3, v_2_r_1, v_2_r_2, v_2_r_3, v_3_r_1, v_3_r_2, v_3_r_3]
                XCTAssertEqual(allReminders.filter({ $0.raw_performed!.count == 3 }).count, allReminders.count)
                allReminders.forEach() {
                    $0.raw_performed!.forEach() {
                        let p = $0 as! CD_ReminderPerform
                        XCTAssertNil(p.raw_migrated)
                    }
                }

                let destPerforms = performs.map({ $0.raw_date! }).sorted(by: { $0 > $1 })
                XCTAssertEqual(srcPerforms, destPerforms)
            case .failure(let error):
                XCTFail("Migration failed with error: \(error)")
            }
        }

        let wait2 = XCTestExpectation()
        wait2.expectedFulfillmentCount = 3
        self.token = progress.observe(\.fractionCompleted) { _, _ in
            wait2.fulfill()
        }

        self.wait(for: [wait1, wait2], timeout: 10)
    }
}

class RealmToCoreDataMigratorScaleTests: RealmToCoreDataMigratorBaseTests {

    var vesselCount: Int { 50 }
    var reminderCount: Int { 30 }
    var performCount: Int { 10 }
    var waitTime: TimeInterval { 30 }

    override func setUpWithError() throws {
        try super.setUpWithError()

        for vIDX in 1...vesselCount {
            try autoreleasepool {
                let v = try source.newReminderVessel(displayName: "v_\(vIDX)", icon: nil).get()
                let rs: [RLM_Reminder] = try (1...reminderCount).map { rIDX in
                    let r = try source.newReminder(for: v).get()
                    try source.update(kind: nil, interval: nil, note: "v_\(vIDX)_r_\(rIDX)", in: r).get()
                    return (r as! RLM_ReminderWrapper).wrappedObject
                }
                for _ in 1...performCount {
                    try autoreleasepool {
                        try source.appendNewPerform(to: rs).get()
                    }
                }
            }
        }
    }

    func test_migrationScale() {
        let context = self.destination.container.viewContext
        let req_v = CD_ReminderVessel.request
        let req_r = CD_Reminder.request
        let req_p = CD_ReminderPerform.request
        XCTAssertEqual(try? context.fetch(req_v).count, 0)
        XCTAssertEqual(try? context.fetch(req_r).count, 0)
        XCTAssertEqual(try? context.fetch(req_p).count, 0)

        let migrator = RealmToCoreDataMigrator(testingSource: self.source)!
        let wait1 = XCTestExpectation()
        wait1.expectedFulfillmentCount = 1
        let progress = migrator.start(destination: self.destination) { result in
            wait1.fulfill()
            switch result {
            case .success:
                let vessels = try! context.fetch(req_v)
                XCTAssertEqual(vessels.count, self.vesselCount)
                XCTAssertEqual(try? context.fetch(req_r).count, self.vesselCount * self.reminderCount + self.vesselCount)
                XCTAssertEqual(try? context.fetch(req_p).count, self.vesselCount * self.reminderCount * self.performCount)
            case .failure(let error):
                XCTFail("Migration failed with error: \(error)")
            }
        }

        let wait2 = XCTestExpectation()
        wait2.expectedFulfillmentCount = vesselCount
        self.token = progress.observe(\.fractionCompleted) { _, _ in
            wait2.fulfill()
        }

        self.wait(for: [wait1, wait2], timeout: waitTime)
    }
}

class RealmToCoreDataMigrationSearchTests: RealmToCoreDataMigratorBaseTests {

    var sourceVessel: RLM_ReminderVessel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let sourceVessel = try! self.source.newReminderVessel(displayName: "One", icon: .emoji("1️⃣"))
                                           .get() as! RLM_ReminderVesselWrapper
        self.sourceVessel = sourceVessel.wrappedObject
        let migrator = RealmToCoreDataMigrator(testingSource: self.source)!
        _ = migrator.start(destination: self.destination) { result in
            switch result {
            case .success:
                break
            case .failure:
                XCTFail()
            }
        }
        // Let the migration happen
        Thread.sleep(forTimeInterval: 0.2)
    }

    func test_search_vesselCollection() {
        let id = Identifier(rawValue: self.sourceVessel.uuid)
        let query = try! self.destination.allVessels(sorted: .displayName, ascending: true).get()
        let wait = XCTestExpectation()
        self.token = query.test_observe_loadData { data in
            wait.fulfill()
            let idx = data.indexOfItem(with: id)
            XCTAssertEqual(idx!, 0)
        }
        self.wait(for: [wait], timeout: 0.3)
    }

    func test_search_reminderCollection() {
        let id = Identifier(rawValue: self.sourceVessel.reminders.first!.uuid)
        let query = try! self.destination.enabledReminders(sorted: .nextPerformDate, ascending: true).get()
        let wait = XCTestExpectation()
        self.token = query.test_observe_loadData { data in
            wait.fulfill()
            let idx = data.indexOfItem(with: id)
            XCTAssertEqual(idx, 0)
        }
        self.wait(for: [wait], timeout: 0.3)
    }

    func test_search_reminderGroupedCollection() {
        let id = Identifier(rawValue: self.sourceVessel.reminders.first!.uuid)
        let query = try! self.destination.groupedReminders().get()
        let wait = XCTestExpectation()
        self.token = query.test_observe_loadData { data in
            wait.fulfill()
            let indexPath = data.indexOfItem(with: id)
            XCTAssertEqual(indexPath, .init(row: 0, section: 0))
        }
        self.wait(for: [wait], timeout: 0.3)
    }

    func test_search_basicController_vessel() {
        let id = Identifier(rawValue: self.sourceVessel.uuid)
        let _vessel = try! self.destination.reminderVessel(matching: id).get()
        let vessel = (_vessel as! CD_ReminderVesselWrapper).wrappedObject
        XCTAssertEqual(vessel.raw_migrated?.raw_realmIdentifier, self.sourceVessel.uuid)
        XCTAssertEqual(vessel.raw_displayName, self.sourceVessel.displayName!)
    }

    func test_search_basicController_reminder() {
        let id = Identifier(rawValue: self.sourceVessel.reminders.first!.uuid)
        let _reminder = try! self.destination.reminder(matching: id).get()
        let reminder = (_reminder as! CD_ReminderWrapper).wrappedObject
        XCTAssertEqual(reminder.raw_migrated?.raw_realmIdentifier, self.sourceVessel.reminders.first!.uuid)
    }

}

/*
class RealmToCoreDataMigratorInsaneScaleTests: RealmToCoreDataMigratorScaleTests {
    override var vesselCount: Int { 500 }
    override var reminderCount: Int { 30 }
    override var performCount: Int { 10 }
    override var waitTime: TimeInterval { 2*60 }
}

class RealmToCoreDataMigratorSuperInsaneScaleTests: RealmToCoreDataMigratorScaleTests {
    override var vesselCount: Int { 1000 }
    override var reminderCount: Int { 50 }
    override var performCount: Int { 20 }
    override var waitTime: TimeInterval { 10*60 }
}
*/
