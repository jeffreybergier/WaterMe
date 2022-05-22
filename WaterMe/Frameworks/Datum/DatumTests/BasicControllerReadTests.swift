//
//  BasicControllerTests.swift
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
@testable import Datum

class BasicControllerReadTests: DatumTestsBase {

    // MARK: Vessels

    private func vesselSortingSetup() throws -> ReminderVessel {
        _ = try self.basicController.newReminderVessel(displayName: "A", icon: nil).get()
        _ = try self.basicController.newReminderVessel(displayName: "C", icon: nil).get()
        return try self.basicController.newReminderVessel(displayName: "B", icon: nil).get()
    }

//    func allVessels(sorted: ReminderVesselSortOrder, ascending: Bool) -> Result<AnyCollectionQuery<ReminderVessel, Int>, DatumError>

    func test_vessel_sort_name_ascend() {
        _ = try! self.vesselSortingSetup()
        let query = try! self.basicController.allVessels(sorted: .displayName, ascending: true).get()
        let wait = XCTestExpectation()
        self.token = query.test_observe_loadData { data in
            wait.fulfill()
            XCTAssertEqual(data.count, 3)
            XCTAssertEqual(data[0]!.displayName!, "A")
            XCTAssertEqual(data[1]!.displayName!, "B")
            XCTAssertEqual(data[2]!.displayName!, "C")
        }
        self.wait(for: [wait], timeout: 0.1)
    }

    func test_vessel_sort_name_descend() {
        _ = try! self.vesselSortingSetup()
        let query = try! self.basicController.allVessels(sorted: .displayName, ascending: false).get()
        let wait = XCTestExpectation()
        self.token = query.test_observe_loadData { data in
            wait.fulfill()
            XCTAssertEqual(data.count, 3)
            XCTAssertEqual(data[0]!.displayName!, "C")
            XCTAssertEqual(data[1]!.displayName!, "B")
            XCTAssertEqual(data[2]!.displayName!, "A")
        }
        self.wait(for: [wait], timeout: 0.1)
    }

    //    func reminderVessel(matching identifier: Identifier) -> Result<ReminderVessel, DatumError>

    func test_vessel_load_byIdentifier() {
        let input = try! self.vesselSortingSetup()
        let inputIdentifier = Identifier(rawValue: input.uuid)
        let output = try! self.basicController.reminderVessel(matching: inputIdentifier).get()
        XCTAssertEqual(input.uuid, output.uuid)
    }

    // MARK: Reminders

    private func reminderSortingSetup() throws -> Reminder {
        let vessel = try self.basicController.newReminderVessel(displayName: "A", icon: nil).get()
        let water = try self.basicController.newReminder(for: vessel).get()
        let trim = try self.basicController.newReminder(for: vessel).get()
        let fertilize = try self.basicController.newReminder(for: vessel).get()
        let mist = try self.basicController.newReminder(for: vessel).get()
        let move = try self.basicController.newReminder(for: vessel).get()
        let other = try self.basicController.newReminder(for: vessel).get()
        try self.basicController.update(kind: .water, interval: 8, isEnabled: true, note: "K", in: water).get()
        try self.basicController.update(kind: .trim, interval: 4, isEnabled: true, note: "P", in: trim).get()
        try self.basicController.update(kind: .fertilize, interval: 10, isEnabled: true, note: "A", in: fertilize).get()
        try self.basicController.update(kind: .mist, interval: 9, isEnabled: true, note: "Z", in: mist).get()
        try self.basicController.update(kind: .move(location: "ZZZ"), interval: 11, isEnabled: true, note: "C", in: move).get()
        try self.basicController.update(kind: .other(description: "YYY"), interval: 2, isEnabled: true, note: "M", in: other).get()
        if self.basicController is CD_BasicController {
            // Test that Disabled reminders work properly in CD only
            let disabled = try self.basicController.newReminder(for: vessel).get()
            try self.basicController.update(kind: .other(description: "xxDDxx"), interval: 2, isEnabled: false, note: "Disabled", in: disabled).get()
        }
        try self.basicController.appendNewPerformToReminders(with:
            [water, trim, fertilize, mist, move, other].map { Identifier(rawValue: $0.uuid) }
        ).get()
        return mist
    }

    /// This one is already really well tested in `GroupedReminderCollectionTests`
    //    func groupedReminders() -> Result<AnyCollectionQuery<Reminder, IndexPath>, DatumError>

    //    func allReminders(sorted: ReminderSortOrder, ascending: Bool) -> Result<AnyCollectionQuery<Reminder, Int>, DatumError>

    func test_reminder_sort_kind_ascend() {
        _ = try! self.reminderSortingSetup()
        let query = try! self.basicController.enabledReminders(sorted: .kind, ascending: true).get()
        let wait = XCTestExpectation()
        self.token = query.test_observe_loadData { data in
            wait.fulfill()
            XCTAssertEqual(data.count, 7)
            XCTAssertEqual(data[0]!.kind, .fertilize)
            XCTAssertEqual(data[1]!.kind, .mist)
            XCTAssertEqual(data[2]!.kind, .move(location: "ZZZ"))
            XCTAssertEqual(data[3]!.kind, .other(description: "YYY"))
            XCTAssertEqual(data[4]!.kind, .trim)
            XCTAssertEqual(data[5]!.kind, .water)
            XCTAssertEqual(data[6]!.kind, .water)
        }
        self.wait(for: [wait], timeout: 0.1)
    }

    func test_reminder_sort_kind_descend() {
        _ = try! self.reminderSortingSetup()
        let query = try! self.basicController.enabledReminders(sorted: .kind, ascending: false).get()
        let wait = XCTestExpectation()
        self.token = query.test_observe_loadData { data in
            wait.fulfill()
            XCTAssertEqual(data.count, 7)
            XCTAssertEqual(data[6]!.kind, .fertilize)
            XCTAssertEqual(data[5]!.kind, .mist)
            XCTAssertEqual(data[4]!.kind, .move(location: "ZZZ"))
            XCTAssertEqual(data[3]!.kind, .other(description: "YYY"))
            XCTAssertEqual(data[2]!.kind, .trim)
            XCTAssertEqual(data[1]!.kind, .water)
            XCTAssertEqual(data[0]!.kind, .water)
        }
        self.wait(for: [wait], timeout: 0.1)
    }

    func test_reminder_sort_interval_ascend() {
        _ = try! self.reminderSortingSetup()
        let query = try! self.basicController.enabledReminders(sorted: .interval, ascending: true).get()
        let wait = XCTestExpectation()
        self.token = query.test_observe_loadData { data in
            wait.fulfill()
            XCTAssertEqual(data.count, 7)
            XCTAssertEqual(data[0]!.interval, 2)
            XCTAssertEqual(data[1]!.interval, 4)
            XCTAssertEqual(data[2]!.interval, 7)
            XCTAssertEqual(data[3]!.interval, 8)
            XCTAssertEqual(data[4]!.interval, 9)
            XCTAssertEqual(data[5]!.interval, 10)
            XCTAssertEqual(data[6]!.interval, 11)
        }
        self.wait(for: [wait], timeout: 0.1)
    }

    func test_reminder_sort_interval_descend() {
        _ = try! self.reminderSortingSetup()
        let query = try! self.basicController.enabledReminders(sorted: .interval, ascending: false).get()
        let wait = XCTestExpectation()
        self.token = query.test_observe_loadData { data in
            wait.fulfill()
            XCTAssertEqual(data.count, 7)
            XCTAssertEqual(data[6]!.interval, 2)
            XCTAssertEqual(data[5]!.interval, 4)
            XCTAssertEqual(data[4]!.interval, 7)
            XCTAssertEqual(data[3]!.interval, 8)
            XCTAssertEqual(data[2]!.interval, 9)
            XCTAssertEqual(data[1]!.interval, 10)
            XCTAssertEqual(data[0]!.interval, 11)
        }
        self.wait(for: [wait], timeout: 0.1)
    }

    func test_reminder_sort_note_ascend() {
        _ = try! self.reminderSortingSetup()
        let query = try! self.basicController.enabledReminders(sorted: .note, ascending: true).get()
        let wait = XCTestExpectation()
        self.token = query.test_observe_loadData { data in
            wait.fulfill()
            XCTAssertEqual(data.count, 7)
            XCTAssertNil(data[0]!.note)
            XCTAssertEqual(data[1]!.note!, "A")
            XCTAssertEqual(data[2]!.note!, "C")
            XCTAssertEqual(data[3]!.note!, "K")
            XCTAssertEqual(data[4]!.note!, "M")
            XCTAssertEqual(data[5]!.note!, "P")
            XCTAssertEqual(data[6]!.note!, "Z")
        }
        self.wait(for: [wait], timeout: 0.1)
    }

    func test_reminder_sort_note_descend() {
        _ = try! self.reminderSortingSetup()
        let query = try! self.basicController.enabledReminders(sorted: .note, ascending: false).get()
        let wait = XCTestExpectation()
        self.token = query.test_observe_loadData { data in
            wait.fulfill()
            XCTAssertEqual(data.count, 7)
            XCTAssertNil(data[6]!.note)
            XCTAssertEqual(data[5]!.note!, "A")
            XCTAssertEqual(data[4]!.note!, "C")
            XCTAssertEqual(data[3]!.note!, "K")
            XCTAssertEqual(data[2]!.note!, "M")
            XCTAssertEqual(data[1]!.note!, "P")
            XCTAssertEqual(data[0]!.note!, "Z")
        }
        self.wait(for: [wait], timeout: 0.1)
    }

    func test_reminder_sort_nextPerformDate_ascend() {
        _ = try! self.reminderSortingSetup()
        let query = try! self.basicController.enabledReminders(sorted: .nextPerformDate, ascending: true).get()
        let wait = XCTestExpectation()
        self.token = query.test_observe_loadData { data in
            wait.fulfill()
            XCTAssertEqual(data.count, 7)
            XCTAssertNil(data[0]!.nextPerformDate)
            XCTAssertEqual(data[1]!.interval, 2)
            XCTAssertEqual(data[2]!.interval, 4)
            XCTAssertEqual(data[3]!.interval, 8)
            XCTAssertEqual(data[4]!.interval, 9)
            XCTAssertEqual(data[5]!.interval, 10)
            XCTAssertEqual(data[6]!.interval, 11)
        }
        self.wait(for: [wait], timeout: 0.1)
    }

    func test_reminder_sort_nextPerformDate_descend() {
        _ = try! self.reminderSortingSetup()
        let query = try! self.basicController.enabledReminders(sorted: .nextPerformDate, ascending: false).get()
        let wait = XCTestExpectation()
        self.token = query.test_observe_loadData { data in
            wait.fulfill()
            XCTAssertEqual(data.count, 7)
            XCTAssertNil(data[6]!.nextPerformDate)
            XCTAssertEqual(data[5]!.interval, 2)
            XCTAssertEqual(data[4]!.interval, 4)
            XCTAssertEqual(data[3]!.interval, 8)
            XCTAssertEqual(data[2]!.interval, 9)
            XCTAssertEqual(data[1]!.interval, 10)
            XCTAssertEqual(data[0]!.interval, 11)
        }
        self.wait(for: [wait], timeout: 0.1)
    }

    //    func reminder(matching identifier: Identifier) -> Result<Reminder, DatumError>

    func test_reminder_load_byIdentifier() {
        let input = try! self.reminderSortingSetup()
        let inputIdentifier = Identifier(rawValue: input.uuid)
        let output = try! self.basicController.reminder(matching: inputIdentifier).get()
        XCTAssertEqual(input.uuid, output.uuid)
        XCTAssertEqual(input.kind, output.kind)
        XCTAssertEqual(input.note!, output.note!)
        XCTAssertEqual(input.interval, output.interval)
    }
}
