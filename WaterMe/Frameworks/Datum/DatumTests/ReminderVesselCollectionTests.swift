//
//  ReminderVesselCollectionTests.swift
//  DatumTests
//
//  Created by Jeffrey Bergier on 2020/05/28.
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

class ReminderVesselCollectionTests: DatumTestsBase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        try self.setUpSmall()
    }

    func test_load() {
        let query = try! self.basicController.allVessels(sorted: .displayName, ascending: true).get()
        let wait = XCTestExpectation()
        self.token = query.test_observe_loadData() { data in
            wait.fulfill()
            let count = data.count
            XCTAssertEqual(count, 2)
            XCTAssertEqual(data[count - 1]!.displayName!, "200番花")
        }
        self.wait(for: [wait], timeout: 0.1)
    }

    func test_map() {
        let query = try! self.basicController.allVessels(sorted: .displayName, ascending: true).get()
        let wait = XCTestExpectation()
        self.token = query.test_observe_loadData() { data in
            wait.fulfill()
            let preCount = data.count
            let mapped: [String?] = data.map() { $0!.displayName }
            XCTAssertEqual(preCount, mapped.count)
            XCTAssertEqual(mapped[0], "100番花")
            XCTAssertEqual(mapped[preCount - 1]!, data[preCount - 1]!.displayName!)
        }
        self.wait(for: [wait], timeout: 0.1)
    }

    func test_compactMap() {
        let query = try! self.basicController.allVessels(sorted: .displayName, ascending: true).get()
        let wait = XCTestExpectation()
        self.token = query.test_observe_loadData() { data in
            wait.fulfill()
            let preCount = data.count
            let mapped: [String] = data.compactMap() { $0!.displayName }
            XCTAssertEqual(mapped.count, preCount) // 2 of the notes in this collection are nil
            XCTAssertEqual(mapped.last!, data[preCount - 1]!.displayName!)
        }
        self.wait(for: [wait], timeout: 0.1)
    }

    func test_indexOfItem() {
        let query = try! self.basicController.allVessels(sorted: .displayName, ascending: true).get()
        let wait = XCTestExpectation()
        let inputIndex = 1
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
        let query = try! self.basicController.allVessels(sorted: .displayName, ascending: true).get()
        let wait = XCTestExpectation()
        let inputIndex = 1
        self.token = query.test_observe_loadData() { data in
            wait.fulfill()
            let input = data[inputIndex]!
            let identifier = Identifier(rawValue: input.uuid)
            let outputIndex = data.indexOfItem(with: identifier)!
            let output = data[outputIndex]!
            XCTAssertEqual(outputIndex, inputIndex)
            XCTAssertEqual(input.uuid, output.uuid)
        }
        self.wait(for: [wait], timeout: 0.1)
    }

    func test_update_deletions() {
        let query = try! self.basicController.allVessels(sorted: .displayName, ascending: true).get()
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

    func test_update_insert() {
        let query = try! self.basicController.allVessels(sorted: .displayName, ascending: true).get()
        let wait = XCTestExpectation()
        wait.expectedFulfillmentCount = 1
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
        let query = try! self.basicController.allVessels(sorted: .displayName, ascending: true).get()
        let vessel = try! self.basicController.newReminderVessel(displayName: "ZZZzzz",
                                                                 icon: .emoji("🤨")).get()
        let wait = XCTestExpectation()
        wait.expectedFulfillmentCount = 1
        self.token = query.test_observe_receiveUpdates() { (_, changes) in
            wait.fulfill()
            XCTAssertEqual(changes.insertions.count, 0)
            XCTAssertEqual(changes.modifications.count, 1)
            XCTAssertEqual(changes.deletions.count, 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            try! self.basicController.update(displayName: nil,
                                             icon: .emoji("🚨"),
                                             in: vessel).get()
        }
        self.wait(for: [wait], timeout: 0.3)
    }
}
