//
//  GroupedReminderCollectionTests.swift
//  DatumTests
//
//  Created by Jeffrey Bergier on 2020/05/29.
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
@testable import DatumL

class GroupedReminderCollectionTests: DatumTestsBase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        try self.setUpSmall()
    }

    func test_indexOfItem() {
        let query = try! self.basicController.groupedReminders().get()
        let wait = XCTestExpectation()
        let inputIndex = IndexPath(row: 3, section: 4)
        self.token = query.test_observe_loadData() { data in
            wait.fulfill()
            let input = data[inputIndex]!
            let outputIndex = data.index(of: input)!
            let output = data[outputIndex]!
            XCTAssertEqual(outputIndex, inputIndex)
            XCTAssertEqual(input.uuid, output.uuid)
        }
        self.wait(for: [wait], timeout: 0.1)
    }

    func test_indexOfIdentifier() {
        let query = try! self.basicController.groupedReminders().get()
        let wait = XCTestExpectation()
        let inputIndex = IndexPath(row: 3, section: 4)
        self.token = query.test_observe_loadData() { data in
            wait.fulfill()
            let input = data[inputIndex]!
            let inputIdentifier = Identifier(rawValue: input.uuid)
            let outputIndex = data.indexOfItem(with: inputIdentifier)!
            let output = data[outputIndex]!
            XCTAssertEqual(outputIndex, inputIndex)
            XCTAssertEqual(input.uuid, output.uuid)
        }
        self.wait(for: [wait], timeout: 0.1)
    }

    func test_update_insert() {
        let query = try! self.basicController.groupedReminders().get()
        let wait = XCTestExpectation()
        self.token = query.test_observe_receiveUpdates() { (_, changes) in
            wait.fulfill()
            XCTAssertEqual(changes.insertions.count, 1)
            XCTAssertEqual(changes.modifications.count, 0)
            XCTAssertEqual(changes.deletions.count, 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            _ = try! self.basicController.newReminderVessel(displayName: nil, icon: nil).get()
        }
        self.wait(for: [wait], timeout: 0.3)
    }

    func test_update_modifications() {
        let query = try! self.basicController.groupedReminders().get()
        let vessel = try! self.basicController.newReminderVessel(displayName: nil, icon: nil).get()
        let reminder = try! self.basicController.newReminder(for: vessel).get()
        let wait = XCTestExpectation()
        self.token = query.test_observe_receiveUpdates() { (_, changes) in
            wait.fulfill()
            XCTAssertEqual(changes.insertions.count, 0)
            XCTAssertEqual(changes.modifications.count, 1)
            XCTAssertEqual(changes.deletions.count, 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            try! self.basicController.update(kind: .mist, interval: 10, isEnabled: true, note: "a new note", in: reminder).get()
        }
        self.wait(for: [wait], timeout: 0.3)
    }

    func test_update_deletions() {
        let query = try! self.basicController.groupedReminders().get()
        let vessel = try! self.basicController.newReminderVessel(displayName: nil, icon: nil).get()
        let wait = XCTestExpectation()
        self.token = query.test_observe_receiveUpdates() { (_, changes) in
            wait.fulfill()
            XCTAssertEqual(changes.insertions.count, 0)
            XCTAssertEqual(changes.modifications.count, 0)
            XCTAssertEqual(changes.deletions.count, 1)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            try! self.basicController.delete(vessel: vessel).get()
        }
        self.wait(for: [wait], timeout: 0.3)
    }
}

extension CD_GroupedReminderCollectionTests {
    func test_load() {
        let query = try! self.basicController.groupedReminders().get()
        let wait = XCTestExpectation()
        self.token = query.test_observe_loadData() { data in
            wait.fulfill()
            XCTAssertEqual(data.numberOfSections, 6)
            for section in 0 ..< 7 {
                if section < 6 {
                    XCTAssertEqual(data.numberOfItems(inSection: section),
                                   data.count(at: IndexPath(row: 0, section: section)))
                }
                switch section {
                case 0:
                    XCTAssertEqual(data.numberOfItems(inSection: section), 2)
                    XCTAssertEqual(data[IndexPath(row: 1, section: section)]!.interval, 7)
                case 1:
                    XCTAssertEqual(data.numberOfItems(inSection: section), 0)
                case 2:
                    XCTAssertEqual(data.numberOfItems(inSection: section), 0)
                case 3:
                    XCTAssertEqual(data.numberOfItems(inSection: section), 0)
                case 4:
                    XCTAssertEqual(data.numberOfItems(inSection: section), 6)
                    XCTAssertEqual(data[IndexPath(row: 3, section: section)]!.note!, "Vessel: 200番花: Reminder: 100")
                case 5:
                    XCTAssertEqual(data.numberOfItems(inSection: section), 2)
                    XCTAssertEqual(data[IndexPath(row: 0, section: section)]!.isEnabled, false)
                    XCTAssertEqual(data[IndexPath(row: 1, section: section)]!.isEnabled, false)
                case 6:
                    XCTAssertNil(data.count(at: IndexPath(row: 0, section: section)))
                default:
                    XCTFail()
                }
            }
        }
        self.wait(for: [wait], timeout: 0.1)
    }
}

extension RLM_GroupedReminderCollectionTests {
    func test_load() {
        let query = try! self.basicController.groupedReminders().get()
        let wait = XCTestExpectation()
        self.token = query.test_observe_loadData() { data in
            wait.fulfill()
            XCTAssertEqual(data.numberOfSections, 5)
            for section in 0..<6 {
                if section < 5 {
                    XCTAssertEqual(data.numberOfItems(inSection: section),
                                   data.count(at: IndexPath(row: 0, section: section)))
                }
                switch section {
                case 0:
                    XCTAssertEqual(data.numberOfItems(inSection: section), 2)
                    XCTAssertEqual(data[IndexPath(row: 1, section: section)]!.interval, 7)
                case 1:
                    XCTAssertEqual(data.numberOfItems(inSection: section), 0)
                case 2:
                    XCTAssertEqual(data.numberOfItems(inSection: section), 0)
                case 3:
                    XCTAssertEqual(data.numberOfItems(inSection: section), 0)
                case 4:
                    XCTAssertEqual(data.numberOfItems(inSection: section), 6)
                    XCTAssertEqual(data[IndexPath(row: 3, section: section)]!.note!, "Vessel: 200番花: Reminder: 100")
                case 5:
                    XCTAssertNil(data.count(at: IndexPath(row: 0, section: section)))
                default:
                    XCTFail()
                }
            }
        }
        self.wait(for: [wait], timeout: 0.1)
    }
}
