//
//  BasicControllerClosureTests.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 2020/06/18.
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

class BasicControllerClosureTests: DatumTestsBase {

    //    var remindersDeleted: (([ReminderValue]) -> Void)? { get set }

    func test_remindersDeleted_byDeletingReminder() {
        let exp = XCTestExpectation()
        var item1UUID: String!
        self.basicController.remindersDeleted = { ids in
            exp.fulfill()
            XCTAssertEqual(ids.count, 1)
            XCTAssertEqual(item1UUID, ids.first!.uuid.uuid)
        }
        let vessel = try! self.basicController.newReminderVessel(displayName: nil,
                                                                 icon: nil).get()
        let item1 = try! self.basicController.newReminder(for: vessel).get()
        item1UUID = item1.uuid
        try! self.basicController.delete(reminder: item1).get()
        self.wait(for: [exp], timeout: 0.1)
    }

    func test_remindersDeleted_byDeletingVessel() {
        let exp = XCTestExpectation()
        var item1UUID: String!
        var item2UUID: String!
        self.basicController.remindersDeleted = { ids in
            exp.fulfill()
            XCTAssertEqual(ids.count, 3)
            XCTAssertEqual(ids.filter({ item1UUID == $0.uuid.uuid }).count, 1)
            XCTAssertEqual(ids.filter({ item2UUID == $0.uuid.uuid }).count, 1)
        }
        let vessel = try! self.basicController.newReminderVessel(displayName: nil,
                                                                 icon: nil).get()
        let item1 = try! self.basicController.newReminder(for: vessel).get()
        let item2 = try! self.basicController.newReminder(for: vessel).get()
        item1UUID = item1.uuid
        item2UUID = item2.uuid
        try! self.basicController.delete(vessel: vessel).get()
        self.wait(for: [exp], timeout: 0.1)
    }

    //    var reminderVesselsDeleted: (([ReminderVesselValue]) -> Void)? { get set }

    func test_vesselsDeleted_byDeletingVessel() {
        let exp = XCTestExpectation()
        var vesselID: String!
        self.basicController.reminderVesselsDeleted = { ids in
            exp.fulfill()
            XCTAssertEqual(ids.count, 1)
            XCTAssertEqual(vesselID, ids.first!.uuid.uuid)
        }
        let vessel = try! self.basicController.newReminderVessel(displayName: nil,
                                                                 icon: nil).get()
        vesselID = vessel.uuid
        try! self.basicController.delete(vessel: vessel).get()
        self.wait(for: [exp], timeout: 0.1)
    }

    //    var userDidPerformReminder: (() -> Void)? { get set }

    func test_performedReminder() {
        let exp = XCTestExpectation()
        var item1UUID: String!
        var item2UUID: String!
        self.basicController.userDidPerformReminder = { ids in
            exp.fulfill()
            XCTAssertEqual(ids.count, 2)
            XCTAssertEqual(ids.filter({ item1UUID == $0.uuid.uuid }).count, 1)
            XCTAssertEqual(ids.filter({ item2UUID == $0.uuid.uuid }).count, 1)
        }
        let vessel = try! self.basicController.newReminderVessel(displayName: nil,
                                                                 icon: nil).get()
        let item1 = try! self.basicController.newReminder(for: vessel).get()
        let item2 = try! self.basicController.newReminder(for: vessel).get()
        item1UUID = item1.uuid
        item2UUID = item2.uuid
        try! self.basicController.appendNewPerformToReminders(
            with: [
                .init(rawValue: item1.uuid),
                .init(rawValue: item2.uuid)
            ]
        ).get()
        self.wait(for: [exp], timeout: 0.1)
    }

}
