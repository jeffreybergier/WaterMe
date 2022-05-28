//
//  ReminderTests.swift
//  DatumTests
//
//  Created by Jeffrey Bergier on 2020/06/04.
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
import Calculate
@testable import DatumL

class ReminderTests: DatumTestsBase {

    func test_nilValues() {
        let vessel = try! self.basicController.newReminderVessel(displayName: nil,
                                                               icon: nil).get()
        let item = try! self.basicController.newReminder(for: vessel).get()
        XCTAssertEqual(item.kind, .water)
        XCTAssertEqual(item.interval, 7)
        XCTAssertTrue(item.isEnabled)
        XCTAssertNil(item.note)
        XCTAssertNil(item.nextPerformDate)
        XCTAssertNil(item.lastPerformDate)
        XCTAssertNil(item.isModelComplete)
        XCTAssertEqual(item.vessel!.uuid, vessel.uuid)
    }

    func test_modelComplete() {
        let vessel = try! self.basicController.newReminderVessel(displayName: nil,
                                                               icon: nil).get()
        let item1 = try! self.basicController.newReminder(for: vessel).get()
        let item2 = try! self.basicController.newReminder(for: vessel).get()
        try! self.basicController.update(kind: .move(location: nil), interval: nil, isEnabled: nil, note: nil, in: item1).get()
        try! self.basicController.update(kind: .other(description: nil), interval: nil, isEnabled: nil, note: nil, in: item2).get()
        let item1Error = item1.isModelComplete
        let item2Error = item2.isModelComplete
        XCTAssertNotNil(item1Error)
        XCTAssertNotNil(item2Error)
        XCTAssertEqual(item1Error?._actions[0], .reminderMissingMoveLocation)
        XCTAssertEqual(item1Error?._actions[1], .cancel)
        XCTAssertEqual(item1Error?._actions[2], .saveAnyway)
        XCTAssertEqual(item2Error?._actions[0], .reminderMissingOtherDescription)
        XCTAssertEqual(item2Error?._actions[1], .cancel)
        XCTAssertEqual(item2Error?._actions[2], .saveAnyway)
    }

    func test_updateName_vessel() {
        let vessel = try! self.basicController.newReminderVessel(displayName: nil,
                                                               icon: nil).get()
        let item = try! self.basicController.newReminder(for: vessel).get()
        let wait = XCTestExpectation()
        self.token = item.observe() { change in
            switch change {
            case .change:
                XCTAssertEqual(item.kind, .mist)
                XCTAssertEqual(item.interval, 4)
                XCTAssertEqual(item.note, "A Cool Note")
            case .deleted, .error:
                XCTFail()
            }
            wait.fulfill()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            try! self.basicController.update(kind: .mist, interval: 4, isEnabled: true, note: "A Cool Note", in: item).get()
        }
        self.wait(for: [wait], timeout: 0.3)
    }

    func test_updatePerformDates() {
        let vessel = try! self.basicController.newReminderVessel(displayName: nil,
                                                               icon: nil).get()
        let item = try! self.basicController.newReminder(for: vessel).get()
        XCTAssertNil(item.nextPerformDate)
        XCTAssertNil(item.lastPerformDate)
        let test_lastDate = Date()
        try! self.basicController.appendNewPerformToReminders(
            with: [item].map { Identifier(rawValue: $0.uuid) }
        ).get()
        XCTAssertDatesClose(item.lastPerformDate!, test_lastDate, within: 0.1)
        let test_nextDate = Calendar.current.dateByAddingNumberOfDays(Int(item.interval),
                                                                      to: item.lastPerformDate!)
        XCTAssertDatesClose(item.nextPerformDate!, test_nextDate, within: 0.1)
        try! self.basicController.update(kind: nil, interval: 12, isEnabled: true, note: nil, in: item).get()
        XCTAssertDatesClose(item.lastPerformDate!, test_lastDate, within: 0.1)
        let test_nextDate2 = Calendar.current.dateByAddingNumberOfDays(Int(12),
                                                                      to: item.lastPerformDate!)
        XCTAssertDatesClose(item.nextPerformDate!, test_nextDate2, within: 0.1)
    }
}

extension CD_ReminderTests {
    func test_updateIsEnabled() {
        let vessel = try! self.basicController.newReminderVessel(displayName: nil, icon: nil).get()

        let item = try! self.basicController.newReminder(for: vessel).get()
        XCTAssertTrue(item.isEnabled)

        let wait = XCTestExpectation()
        self.token = item.observe() { change in
            switch change {
            case .change:
                XCTAssertFalse(item.isEnabled)
            case .deleted, .error:
                XCTFail()
            }
            wait.fulfill()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            try! self.basicController.update(kind: nil, interval: nil, isEnabled: false, note: nil, in: item).get()
        }

        self.wait(for: [wait], timeout: 0.3)
    }

    func test_modelComplete_isEnabled() throws {
        let vessel = try self.basicController.newReminderVessel(displayName: nil,
                                                               icon: nil).get()
        let item1 = try self.basicController.newReminder(for: vessel).get()
        try! self.basicController.update(kind: .move(location: nil),
                                         interval: nil,
                                         isEnabled: false,
                                         note: nil,
                                         in: item1).get()
        let item1Error = item1.isModelComplete
        XCTAssertNotNil(item1Error)
        XCTAssertEqual(item1Error?._actions[0], .reminderMissingMoveLocation)
        XCTAssertEqual(item1Error?._actions[1], .reminderMissingEnabled)
        XCTAssertEqual(item1Error?._actions[2], .cancel)
        XCTAssertEqual(item1Error?._actions[3], .saveAnyway)
    }
}

extension RLM_ReminderTests {
    func test_updateIsEnabled() {
        let vessel = try! self.basicController.newReminderVessel(displayName: nil, icon: nil).get()

        let item = try! self.basicController.newReminder(for: vessel).get()
        XCTAssertTrue(item.isEnabled)

        self.token = item.observe() { _ in
            XCTFail()
        }

        let wait = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let result = self.basicController.update(kind: nil, interval: nil, isEnabled: false, note: nil, in: item)
            switch result {
            case .failure(let error):
                XCTAssertEqual(error, .reminderIsEnabledFlagUnavailable)
            case .success:
                XCTFail()
            }
            wait.fulfill()
        }

        self.wait(for: [wait], timeout: 0.3)
    }
}
