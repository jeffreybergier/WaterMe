//
//  BasicControllerCreateUpdateTests.swift
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

class BasicControllerCreateUpdateTests: DatumTestsBase {

//    func update(displayName: String?, icon: ReminderVesselIcon?, in vessel: ReminderVessel) -> Result<Void, DatumError>

    func test_update_vessel_values() {
        let item = try! self.basicController.newReminderVessel(displayName: nil, icon: nil).get()
        XCTAssertNil(item.displayName)
        XCTAssertNil(item.icon)
        XCTAssertEqual(item.kind, .plant)
        try! self.basicController.update(displayName: "お花水", icon: .emoji("🌵"), in: item).get()
        XCTAssertEqual(item.displayName, "お花水")
        XCTAssertEqual(item.icon?.emoji, "🌵")
        XCTAssertEqual(item.kind, .plant)
    }

    func test_update_vessel_nil() {
        let item = try! self.basicController.newReminderVessel(displayName: "お花水", icon: .emoji("🌵")).get()
        XCTAssertEqual(item.displayName, "お花水")
        XCTAssertEqual(item.icon?.emoji, "🌵")
        XCTAssertEqual(item.kind, .plant)
        try! self.basicController.update(displayName: nil, icon: nil, in: item).get()
        XCTAssertEqual(item.displayName, "お花水")
        XCTAssertEqual(item.icon?.emoji, "🌵")
        XCTAssertEqual(item.kind, .plant)
    }

//    func update(kind: ReminderKind?, interval: Int?, note: String?, in reminder: Reminder) -> Result<Void, DatumError>

    func test_update_reminder_values() {
        let vessel = try! self.basicController.newReminderVessel(displayName: nil, icon: nil).get()
        let item = try! self.basicController.newReminder(for: vessel).get()
        XCTAssertNil(item.note)
        XCTAssertEqual(item.kind, .water)
        XCTAssertEqual(item.interval, 7)
        try! self.basicController.update(kind: .move(location: "ベランダー"), interval: 20, isEnabled: true, note: "お花水", in: item).get()
        XCTAssertEqual(item.note, "お花水")
        XCTAssertEqual(item.kind, .move(location: "ベランダー"))
        XCTAssertEqual(item.interval, 20)
    }

    func test_update_reminder_nil() {
        let vessel = try! self.basicController.newReminderVessel(displayName: nil, icon: nil).get()
        let item = try! self.basicController.newReminder(for: vessel).get()
        XCTAssertNil(item.note)
        XCTAssertEqual(item.kind, .water)
        XCTAssertEqual(item.interval, 7)
        try! self.basicController.update(kind: .move(location: "ベランダー"), interval: 20, isEnabled: true, note: "お花水", in: item).get()
        XCTAssertEqual(item.note, "お花水")
        XCTAssertEqual(item.kind, .move(location: "ベランダー"))
        XCTAssertEqual(item.interval, 20)
        try! self.basicController.update(kind: nil, interval: nil, isEnabled: true, note: nil, in: item).get()
        XCTAssertEqual(item.note, "お花水")
        XCTAssertEqual(item.kind, .move(location: "ベランダー"))
        XCTAssertEqual(item.interval, 20)
    }

}

//    func appendNewPerformToReminders(with identifiers: [Identifier]) -> Result<Void, DatumError>
extension RLM_BasicControllerCreateUpdateTests {
    func test_reminder_reminder_appendPerform() {
        let vessel = try! self.basicController.newReminderVessel(displayName: nil, icon: nil).get()
        let _item1 = try! self.basicController.newReminder(for: vessel).get()
        let _item2 = try! self.basicController.newReminder(for: vessel).get()
        let item1 = (_item1 as! RLM_ReminderWrapper).wrappedObject
        let item2 = (_item2 as! RLM_ReminderWrapper).wrappedObject
        XCTAssertEqual(item1.performed.count, 0)
        XCTAssertEqual(item2.performed.count, 0)
        try! self.basicController.appendNewPerformToReminders(
            with: [_item1, _item2].map { .init(rawValue: $0.uuid) }
        ).get()
        XCTAssertEqual(item1.performed.count, 1)
        XCTAssertEqual(item2.performed.count, 1)
    }
}

extension CD_BasicControllerCreateUpdateTests {
    func test_reminder_reminder_appendPerform() {
        let vessel = try! self.basicController.newReminderVessel(displayName: nil, icon: nil).get()
        let _item1 = try! self.basicController.newReminder(for: vessel).get()
        let _item2 = try! self.basicController.newReminder(for: vessel).get()
        let item1 = (_item1 as! CD_ReminderWrapper).wrappedObject
        let item2 = (_item2 as! CD_ReminderWrapper).wrappedObject
        XCTAssertEqual(item1.raw_performed!.count, 0)
        XCTAssertEqual(item2.raw_performed!.count, 0)
        try! self.basicController.appendNewPerformToReminders(
            with: [_item1, _item2].map { .init(rawValue: $0.uuid) }
        ).get()
        XCTAssertEqual(item1.raw_performed!.count, 1)
        XCTAssertEqual(item2.raw_performed!.count, 1)
    }
}
