//
//  SchemaMigrationTests.swift
//  DatumTests
//
//  Created by Jeffrey Bergier on 2021/05/03.
//  Copyright © 2021 Saturday Apps. All rights reserved.
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

@testable import DatumL
import CoreData
import XCTest

private let TestDB1URL     = Bundle(for: NonSyncContainer.self)
                                       .url(forResource: "TestDB", withExtension: "sqlite")!
private let TestDB2URL     = Bundle(for: NonSyncContainer.self)
                                       .url(forResource: "TestDB", withExtension: "sqlite-wal")!
private let StoreParentURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                                    .appendingPathComponent(UUID().uuidString, isDirectory: true)
private let Store1URL      = StoreParentURL.appendingPathComponent("WaterMe.sqlite", isDirectory: false)
private let Store2URL      = StoreParentURL.appendingPathComponent("WaterMe.sqlite-wal", isDirectory: false)

private class NonSyncContainer: NSPersistentContainer {
    override class func defaultDirectoryURL() -> URL {
        return StoreParentURL
    }
}

@available(iOS 14.0, *)
private class SyncContainer: NSPersistentCloudKitContainer {
    override class func defaultDirectoryURL() -> URL {
        return StoreParentURL
    }
}

class CoreDataSchemaMigrationTests: RealmToCoreDataMigratorBaseTests {

    override func setUpWithError() throws {
        try super.setUpWithError()
        let fm = FileManager.default
        try fm.createDirectory(at: StoreParentURL,
                               withIntermediateDirectories: true,
                               attributes: nil)
        try fm.copyItem(at: TestDB1URL, to: Store1URL)
        try fm.copyItem(at: TestDB2URL, to: Store2URL)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        let fm = FileManager.default
        try fm.removeItem(at: StoreParentURL)
    }

    func test_nonSync_initialize_simpleMigration() throws {
        let c = try CD_BasicController(kind: .__testing_withClass(NonSyncContainer.self))
        try self.verifyMigratedData(c)
    }

    @available(iOS 14.0, *)
    func test_sync_initialize_simpleMigration() throws {
        let c = try CD_BasicController(kind: .__testing_withClass(SyncContainer.self))
        try self.verifyMigratedData(c)
    }

    private func verifyMigratedData(_ c: BasicController) throws {
        let reminders = try c.groupedReminders().get()
        let wait = self.expectation(description: "Reminders")
        self.token = reminders.observe {
            switch $0 {
            case .initial(let data):
                XCTAssertEqual(data.numberOfSections, 6)
                XCTAssertEqual(data.numberOfItems(inSection: 0), 9)
                XCTAssertEqual(data.numberOfItems(inSection: 1), 0)
                XCTAssertEqual(data.numberOfItems(inSection: 2), 0)
                XCTAssertEqual(data.numberOfItems(inSection: 3), 0)
                XCTAssertEqual(data.numberOfItems(inSection: 4), 0)
                XCTAssertEqual(data.numberOfItems(inSection: 5), 0)
                let _0_0 = data[IndexPath(row: 0, section: 0)]!
                XCTAssertEqual(_0_0.interval, 1)
                XCTAssertEqual(_0_0.kind, .water)
                XCTAssertNil(_0_0.lastPerformDate)
                XCTAssertEqual(_0_0.note, "Welcome to WaterMe! This is your first plant. Use the button below to edit this plant and make it your own. When you’re ready to add all your plants, tap the ‘Add Plant’ button at the top right of the screen.")
                XCTAssertEqual(_0_0.vessel!.displayName, "Plant 1")
                let _0_1 = data[IndexPath(row: 1, section: 0)]!
                XCTAssertEqual(_0_1.interval, 7)
                XCTAssertEqual(_0_1.kind, .move(location: nil))
                XCTAssertNil(_0_1.lastPerformDate)
                XCTAssertNil(_0_1.note)
                XCTAssertEqual(_0_1.vessel!.displayName, "Dead Rose")
                let _0_2 = data[IndexPath(row: 2, section: 0)]!
                XCTAssertEqual(_0_2.interval, 7)
                XCTAssertEqual(_0_2.kind, .water)
                XCTAssertNil(_0_2.lastPerformDate)
                XCTAssertNil(_0_2.note)
                XCTAssertNil(_0_2.vessel!.displayName)
                let _0_3 = data[IndexPath(row: 3, section: 0)]!
                XCTAssertEqual(_0_3.interval, 1)
                XCTAssertEqual(_0_3.kind, .trim)
                XCTAssertNotNil(_0_3.lastPerformDate)
                XCTAssertNil(_0_3.note)
                XCTAssertEqual(_0_3.vessel!.displayName, "Plant 1")
                let _1_0 = data[IndexPath(row: 8, section: 0)]!
                XCTAssertEqual(_1_0.interval, 7)
                XCTAssertEqual(_1_0.kind, .water)
                XCTAssertNotNil(_1_0.lastPerformDate)
                XCTAssertNil(_1_0.note)
                XCTAssertEqual(_1_0.vessel!.displayName, "Dead Rose")
            case .update, .error:
                XCTFail()
            }
            wait.fulfill()
        }
        self.wait(for: [wait], timeout: 0.3)
    }

}
