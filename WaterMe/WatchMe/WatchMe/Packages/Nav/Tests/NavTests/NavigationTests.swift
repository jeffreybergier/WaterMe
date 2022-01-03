//
//  Created by Jeffrey Bergier on 2022/01/03.
//  Copyright © 2021 Saturday Apps.
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
import Nav
import Model

final class NavigationTests: XCTestCase {
    
    // MARK: Init
    
    func test_case_init_rootList() {
        var nav = Navigation.root()
        nav.state = .TEST_rootList
        var results = self.keyPathsForNonNilAndTrueProperties(nav)
        results.subtract([\.isRootList])
        XCTAssertEqual(results.count, 0)
    }
    
    func test_case_init_rootError() {
        var nav = Navigation.root()
        nav.state = .TEST_rootError
        var results = self.keyPathsForNonNilAndTrueProperties(nav)
        results.subtract([\.isRootError])
        XCTAssertEqual(results.count, 0)
    }
    
    func test_case_init_listMenu() {
        var nav = Navigation.root()
        nav.state = .TEST_listMenu
        var results = self.keyPathsForNonNilAndTrueProperties(nav)
        results.subtract([
            \.isListMenu,
            \.isListMenuData
        ])
        XCTAssertEqual(results.count, 0)
    }
    
    func test_case_init_listWatering() {
        var nav = Navigation.root()
        nav.state = .TEST_listWatering
        var results = self.keyPathsForNonNilAndTrueProperties(nav)
        results.subtract([\.isListWatering])
        XCTAssertEqual(results.count, 0)
    }
    
    func test_case_init_listSummary() {
        var nav = Navigation.root()
        nav.state = .TEST_listSummary
        var results = self.keyPathsForNonNilAndTrueProperties(nav)
        results.subtract([\.isListSummary])
        XCTAssertEqual(results.count, 0)
    }
    
    func test_case_init_listReminderEdit() {
        var nav = Navigation.root()
        nav.state = .TEST_listReminderEdit
        var results = self.keyPathsForNonNilAndTrueProperties(nav)
        results.subtract([\.isListReminderEdit])
        XCTAssertEqual(results.count, 0)
    }
    
    func test_case_init_listVesselEdit() {
        var nav = Navigation.root()
        nav.state = .TEST_listVesselEdit
        var results = self.keyPathsForNonNilAndTrueProperties(nav)
        results.subtract([\.isListVesselEdit])
        XCTAssertEqual(results.count, 0)
    }
    
    func test_case_init_listVesselEditReminderEdit() {
        var nav = Navigation.root()
        nav.state = .TEST_listVesselEditReminderEdit
        var results = self.keyPathsForNonNilAndTrueProperties(nav)
        results.subtract([
            \.isListVesselEdit,
            \.isListVesselEditReminderEdit
        ])
        XCTAssertEqual(results.count, 0)
    }
    
    func test_case_init_listVesselEditEmoji() {
        var nav = Navigation.root()
        nav.state = .TEST_listVesselEditEmoji
        var results = self.keyPathsForNonNilAndTrueProperties(nav)
        results.subtract([
            \.isListVesselEdit,
            \.isListVesselEditEmoji
        ])
        XCTAssertEqual(results.count, 0)
    }
    
    func test_case_init_listSettings() {
        var nav = Navigation.root()
        nav.state = .TEST_listSettings
        var results = self.keyPathsForNonNilAndTrueProperties(nav)
        results.subtract([\.isListSettings])
        XCTAssertEqual(results.count, 0)
    }
    
    func test_case_init_listError() {
        var nav = Navigation.root()
        nav.state = .TEST_listError
        var results = self.keyPathsForNonNilAndTrueProperties(nav)
        results.subtract([\.isListError])
        XCTAssertEqual(results.count, 0)
    }
    
    // MARK: Reset
    
    func test_case_reset_rootList() {
        for state in Navigation.State.TEST_allCases {
            var nav = Navigation(state)
            nav.isRootList = false
            var results = self.keyPathsForNonNilAndTrueProperties(nav)
            results.subtract([\.isRootList])
            XCTAssertEqual(results.count, 0)
        }
    }
    
    func test_case_reset_rootError() {
        for state in Navigation.State.TEST_allCases {
            var nav = Navigation(state)
            nav.isRootError = false
            var results = self.keyPathsForNonNilAndTrueProperties(nav)
            results.subtract([\.isRootList])
            XCTAssertEqual(results.count, 0)
        }
    }
    
    func test_case_reset_listMenu() {
        for state in Navigation.State.TEST_allCases {
            var nav = Navigation(state)
            nav.isListMenu = false
            var results = self.keyPathsForNonNilAndTrueProperties(nav)
            results.subtract([\.isRootList])
            XCTAssertEqual(results.count, 0)
        }
    }
    
    func test_case_reset_listMenuData() {
        for state in Navigation.State.TEST_allCases {
            var nav = Navigation(state)
            nav.isListMenuData = nil
            var results = self.keyPathsForNonNilAndTrueProperties(nav)
            results.subtract([\.isRootList])
            XCTAssertEqual(results.count, 0)
        }
    }
    
    func test_case_reset_listWatering() {
        for state in Navigation.State.TEST_allCases {
            var nav = Navigation(state)
            nav.isListWatering = nil
            var results = self.keyPathsForNonNilAndTrueProperties(nav)
            results.subtract([\.isRootList])
            XCTAssertEqual(results.count, 0)
        }
    }
    
    func test_case_reset_listSummary() {
        for state in Navigation.State.TEST_allCases {
            var nav = Navigation(state)
            nav.isListSummary = nil
            var results = self.keyPathsForNonNilAndTrueProperties(nav)
            results.subtract([\.isRootList])
            XCTAssertEqual(results.count, 0)
        }
    }
    
    func test_case_reset_listReminderEdit() {
        for state in Navigation.State.TEST_allCases {
            var nav = Navigation(state)
            nav.isListReminderEdit = nil
            var results = self.keyPathsForNonNilAndTrueProperties(nav)
            results.subtract([\.isRootList])
            XCTAssertEqual(results.count, 0)
        }
    }
    
    func test_case_reset_listVesselEdit() {
        for state in Navigation.State.TEST_allCases {
            var nav = Navigation(state)
            nav.isListVesselEdit = nil
            var results = self.keyPathsForNonNilAndTrueProperties(nav)
            results.subtract([\.isRootList])
            XCTAssertEqual(results.count, 0)
        }
    }
    
    func test_case_reset_listVesselEditReminderEdit() {
        for state in Navigation.State.TEST_allCases {
            var nav = Navigation(state)
            nav.isListVesselEditReminderEdit = nil
            var results = self.keyPathsForNonNilAndTrueProperties(nav)
            switch state {
            case .listVesselEditReminderEdit, .listVesselEditEmoji, .listVesselEdit:
                results.subtract([\.isListVesselEdit])
            default:
                results.subtract([\.isRootList])
            }
            XCTAssertEqual(results.count, 0)
        }
    }
    
    func test_case_reset_listVesselEditEmoji() {
        for state in Navigation.State.TEST_allCases {
            var nav = Navigation(state)
            nav.isListVesselEditEmoji = nil
            var results = self.keyPathsForNonNilAndTrueProperties(nav)
            switch state {
            case .listVesselEditReminderEdit, .listVesselEditEmoji, .listVesselEdit:
                results.subtract([\.isListVesselEdit])
            default:
                results.subtract([\.isRootList])
            }
            XCTAssertEqual(results.count, 0)
        }
    }
    
    func test_case_reset_listSettings() {
        for state in Navigation.State.TEST_allCases {
            var nav = Navigation(state)
            nav.isListSettings = false
            var results = self.keyPathsForNonNilAndTrueProperties(nav)
            results.subtract([\.isRootList])
            XCTAssertEqual(results.count, 0)
        }
    }
    
    func test_case_reset_listError() {
        for state in Navigation.State.TEST_allCases {
            var nav = Navigation(state)
            nav.isListError = false
            var results = self.keyPathsForNonNilAndTrueProperties(nav)
            results.subtract([\.isRootList])
            XCTAssertEqual(results.count, 0)
        }
    }
    
    // MARK: Helpers
    
    private typealias NavKP = PartialKeyPath<Navigation>
    private func keyPathsForNonNilAndTrueProperties(_ nav: Navigation) -> Set<NavKP> {
        var kps: Set<NavKP> = []
        if nav.isRootList == true {
            kps.insert(\.isRootList)
        }
        if nav.isRootError == true {
            kps.insert(\.isRootError)
        }
        if nav.isListMenu == true {
            kps.insert(\.isListMenu)
        }
        if nav.isListMenuData != nil {
            kps.insert(\.isListMenuData)
        }
        if nav.isListWatering != nil {
            kps.insert(\.isListWatering)
        }
        if nav.isListSummary != nil {
            kps.insert(\.isListSummary)
        }
        if nav.isListReminderEdit != nil {
            kps.insert(\.isListReminderEdit)
        }
        if nav.isListVesselEdit != nil {
            kps.insert(\.isListVesselEdit)
        }
        if nav.isListVesselEditReminderEdit != nil {
            kps.insert(\.isListVesselEditReminderEdit)
        }
        if nav.isListVesselEditEmoji != nil {
            kps.insert(\.isListVesselEditEmoji)
        }
        if nav.isListSettings == true {
            kps.insert(\.isListSettings)
        }
        if nav.isListError == true {
            kps.insert(\.isListError)
        }
        
        // Will cause compile failure when ENUM changes
        switch Navigation.State.rootList {
        case .rootList: break
        case .rootError: break
        case .listMenu(_): break
        case .listWatering(_): break
        case .listSummary(_): break
        case .listReminderEdit(_): break
        case .listVesselEdit(_): break
        case .listVesselEditReminderEdit(_): break
        case .listVesselEditEmoji(_): break
        case .listSettings: break
        case .listError: break
        }
        return kps
    }
}


extension Navigation.State {
    
    static let TEST_reminderID = Reminder.アイディ("ABC123")
    static let TEST_vesselID = Vessel.アイディ("DEF456")
    static let TEST_rootList: Navigation.State = .rootList
    static let TEST_rootError: Navigation.State = .rootError
    static let TEST_listMenu: Navigation.State = .listMenu(.init(TEST_reminderID, TEST_vesselID))
    static let TEST_listWatering: Navigation.State = .listWatering(.init([TEST_reminderID]))
    static let TEST_listSummary: Navigation.State = .listSummary(.init(TEST_reminderID))
    static let TEST_listReminderEdit: Navigation.State = .listReminderEdit(.init(TEST_reminderID))
    static let TEST_listVesselEdit: Navigation.State = .listVesselEdit(.init(TEST_vesselID))
    static let TEST_listVesselEditReminderEdit: Navigation.State = .listVesselEditReminderEdit(.init(TEST_reminderID, TEST_vesselID))
    static let TEST_listVesselEditEmoji: Navigation.State = .listVesselEditEmoji(.init(TEST_vesselID))
    static let TEST_listSettings: Navigation.State = .listSettings
    static let TEST_listError: Navigation.State = .listError
    static let TEST_allCases: [Navigation.State] = [
        TEST_rootList,
        TEST_rootError,
        TEST_listMenu,
        TEST_listWatering,
        TEST_listSummary,
        TEST_listReminderEdit,
        TEST_listVesselEdit,
        TEST_listVesselEditReminderEdit,
        TEST_listVesselEditEmoji,
        TEST_listSettings,
        TEST_listError,
    ]
}
