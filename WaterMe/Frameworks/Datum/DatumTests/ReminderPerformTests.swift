//
//  ReminderPerformTests.swift
//  DatumTests
//
//  Created by Jeffrey Bergier on 2020/06/15.
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

class ReminderPerformTests: DatumTestsBase {

    fileprivate func newItem() -> Reminder {
        let vessel = try! self.basicController.newReminderVessel(displayName: nil,
                                                               icon: nil).get()
        return try! self.basicController.newReminder(for: vessel).get()
    }

}

extension CD_ReminderPerformTests {

    func test_append() {
        let _item = self.newItem() as! CD_ReminderWrapper
        let item = _item.wrappedObject
        XCTAssertEqual(item.raw_performed!.count, 0)
        try! self.basicController.appendNewPerformToReminders(with: [.init(rawValue: _item.uuid)]).get()
        XCTAssertEqual(item.raw_performed!.count, 1)
        try! self.basicController.appendNewPerformToReminders(with: [.init(rawValue: _item.uuid)]).get()
        XCTAssertEqual(item.raw_performed!.count, 2)
    }

    func test_perform_dates() {
        let _item = self.newItem() as! CD_ReminderWrapper
        let item = _item.wrappedObject
        XCTAssertEqual(item.raw_performed!.count, 0)
        let now = Date()
        let future = Calendar.current.dateByAddingNumberOfDays(_item.interval, to: now)
        try! self.basicController.appendNewPerformToReminders(with: [.init(rawValue: _item.uuid)]).get()
        XCTAssertEqual(item.raw_performed!.count, 1)
        let perform = item.raw_performed!.allObjects.first! as! CD_ReminderPerform
        XCTAssertDatesClose(perform.raw_date!, now, within: 1)
        XCTAssertDatesClose(_item.lastPerformDate!, now, within: 1)
        XCTAssertDatesClose(_item.nextPerformDate!, future, within: 1)
    }
}

extension RLM_ReminderPerformTests {

    func test_append() {
        let reminder = self.newItem() as! RLM_ReminderWrapper
        let item = reminder.wrappedObject
        XCTAssertEqual(item.performed.count, 0)
        try! self.basicController.appendNewPerformToReminders(with: [.init(rawValue: reminder.uuid)]).get()
        XCTAssertEqual(item.performed.count, 1)
        try! self.basicController.appendNewPerformToReminders(with: [.init(rawValue: reminder.uuid)]).get()
        XCTAssertEqual(item.performed.count, 2)
    }

    func test_perform_dates() {
        let _item = self.newItem() as! RLM_ReminderWrapper
        let item = _item.wrappedObject
        XCTAssertEqual(item.performed.count, 0)
        let now = Date()
        let future = Calendar.current.dateByAddingNumberOfDays(_item.interval, to: now)
        try! self.basicController.appendNewPerformToReminders(with: [.init(rawValue: _item.uuid)]).get()
        XCTAssertEqual(item.performed.count, 1)
        let perform = item.performed.first!
        XCTAssertDatesClose(perform.date, now, within: 1)
        XCTAssertDatesClose(_item.lastPerformDate!, now, within: 1)
        XCTAssertDatesClose(_item.nextPerformDate!, future, within: 1)
    }
}

public func XCTAssertDatesClose(_ expression1: @autoclosure () throws -> Date,
                                _ expression2: @autoclosure () throws -> Date,
                                within interval: TimeInterval,
                                _ message: @autoclosure () -> String = "",
                                file: StaticString = #file,
                                line: UInt = #line)
{
    do {
        let date1 = try expression1()
        let date2 = try expression2()
        let gap = date1.timeIntervalSince(date2)
        let gapABS = abs(gap)
        guard gapABS > interval else { return }
        XCTAssertEqual(date1, date2, message(), file: file, line: line)
    } catch {
        XCTFail(error.localizedDescription)
    }
}
