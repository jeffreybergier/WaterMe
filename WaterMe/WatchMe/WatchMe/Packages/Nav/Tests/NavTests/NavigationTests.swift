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
        results.subtract([\.isRootアList])
        XCTAssertEqual(results.count, 0)
    }
    
    func test_case_init_rootError() {
        var nav = Navigation.root()
        nav.state = .TEST_rootError
        var results = self.keyPathsForNonNilAndTrueProperties(nav)
        results.subtract([\.isRootアError])
        XCTAssertEqual(results.count, 0)
    }
    
    func test_case_init_listMenu() {
        var nav = Navigation.root()
        nav.state = .TEST_listMenu
        var results = self.keyPathsForNonNilAndTrueProperties(nav)
        results.subtract([
            \.isRootアListアMenu,
            \.isRootアListアMenuData
        ])
        XCTAssertEqual(results.count, 0)
    }
    
    func test_case_init_listWatering() {
        var nav = Navigation.root()
        nav.state = .TEST_listWatering
        var results = self.keyPathsForNonNilAndTrueProperties(nav)
        results.subtract([\.isRootアListアWatering])
        XCTAssertEqual(results.count, 0)
    }
    
    func test_case_init_listSummary() {
        var nav = Navigation.root()
        nav.state = .TEST_listSummary
        var results = self.keyPathsForNonNilAndTrueProperties(nav)
        results.subtract([\.isRootアListアSummary])
        XCTAssertEqual(results.count, 0)
    }
    
    func test_case_init_listReminderEdit() {
        var nav = Navigation.root()
        nav.state = .TEST_listReminderEdit
        var results = self.keyPathsForNonNilAndTrueProperties(nav)
        results.subtract([\.isRootアListアReminderEdit])
        XCTAssertEqual(results.count, 0)
    }
    
    func test_case_init_listVesselEdit() {
        var nav = Navigation.root()
        nav.state = .TEST_listVesselEdit
        var results = self.keyPathsForNonNilAndTrueProperties(nav)
        results.subtract([\.isRootアListアVesselEdit])
        XCTAssertEqual(results.count, 0)
    }
    
    func test_case_init_listVesselEditReminderEdit() {
        var nav = Navigation.root()
        nav.state = .TEST_listVesselEditReminderEdit
        var results = self.keyPathsForNonNilAndTrueProperties(nav)
        results.subtract([
            \.isRootアListアVesselEdit,
            \.isRootアListアVesselEditアReminderEdit
        ])
        XCTAssertEqual(results.count, 0)
    }
    
    func test_case_init_listVesselEditEmoji() {
        var nav = Navigation.root()
        nav.state = .TEST_listVesselEditEmoji
        var results = self.keyPathsForNonNilAndTrueProperties(nav)
        results.subtract([
            \.isRootアListアVesselEdit,
            \.isRootアListアVesselEditアEmoji
        ])
        XCTAssertEqual(results.count, 0)
    }
    
    func test_case_init_listSettings() {
        var nav = Navigation.root()
        nav.state = .TEST_listSettings
        var results = self.keyPathsForNonNilAndTrueProperties(nav)
        results.subtract([\.isRootアListアSettings])
        XCTAssertEqual(results.count, 0)
    }
    
    func test_case_init_listError() {
        var nav = Navigation.root()
        nav.state = .TEST_listError
        var results = self.keyPathsForNonNilAndTrueProperties(nav)
        results.subtract([\.isRootアListアError])
        XCTAssertEqual(results.count, 0)
    }
    
    // MARK: Reset
    
    func test_case_reset_rootList() {
        for state in Navigation.State.TEST_allCases {
            var nav = Navigation(state)
            nav.isRootアList = false
            var results = self.keyPathsForNonNilAndTrueProperties(nav)
            results.subtract([\.isRootアList])
            XCTAssertEqual(results.count, 0)
        }
    }
    
    func test_case_reset_rootError() {
        for state in Navigation.State.TEST_allCases {
            var nav = Navigation(state)
            nav.isRootアListアError = false
            var results = self.keyPathsForNonNilAndTrueProperties(nav)
            results.subtract([\.isRootアList])
            XCTAssertEqual(results.count, 0)
        }
    }
    
    func test_case_reset_listMenu() {
        for state in Navigation.State.TEST_allCases {
            var nav = Navigation(state)
            nav.isRootアListアMenu = false
            var results = self.keyPathsForNonNilAndTrueProperties(nav)
            results.subtract([\.isRootアList])
            XCTAssertEqual(results.count, 0)
        }
    }
    
    func test_case_reset_listMenuData() {
        for state in Navigation.State.TEST_allCases {
            var nav = Navigation(state)
            nav.isRootアListアMenuData = nil
            var results = self.keyPathsForNonNilAndTrueProperties(nav)
            results.subtract([\.isRootアList])
            XCTAssertEqual(results.count, 0)
        }
    }
    
    func test_case_reset_listWatering() {
        for state in Navigation.State.TEST_allCases {
            var nav = Navigation(state)
            nav.isRootアListアWatering = nil
            var results = self.keyPathsForNonNilAndTrueProperties(nav)
            results.subtract([\.isRootアList])
            XCTAssertEqual(results.count, 0)
        }
    }
    
    func test_case_reset_listSummary() {
        for state in Navigation.State.TEST_allCases {
            var nav = Navigation(state)
            nav.isRootアListアSummary = nil
            var results = self.keyPathsForNonNilAndTrueProperties(nav)
            results.subtract([\.isRootアList])
            XCTAssertEqual(results.count, 0)
        }
    }
    
    func test_case_reset_listReminderEdit() {
        for state in Navigation.State.TEST_allCases {
            var nav = Navigation(state)
            nav.isRootアListアSummary = nil
            var results = self.keyPathsForNonNilAndTrueProperties(nav)
            results.subtract([\.isRootアList])
            XCTAssertEqual(results.count, 0)
        }
    }
    
    func test_case_reset_listVesselEdit() {
        for state in Navigation.State.TEST_allCases {
            var nav = Navigation(state)
            nav.isRootアListアVesselEdit = nil
            var results = self.keyPathsForNonNilAndTrueProperties(nav)
            results.subtract([\.isRootアList])
            XCTAssertEqual(results.count, 0)
        }
    }
    
    func test_case_reset_listVesselEditReminderEdit() {
        for state in Navigation.State.TEST_allCases {
            var nav = Navigation(state)
            nav.isRootアListアVesselEditアReminderEdit = nil
            var results = self.keyPathsForNonNilAndTrueProperties(nav)
            switch state {
            case .rootアListアVesselEditアReminderEdit, .rootアListアVesselEditアEmoji, .rootアListアVesselEdit:
                results.subtract([\.isRootアListアVesselEdit])
            default:
                results.subtract([\.isRootアList])
            }
            XCTAssertEqual(results.count, 0)
        }
    }
    
    func test_case_reset_listVesselEditEmoji() {
        for state in Navigation.State.TEST_allCases {
            var nav = Navigation(state)
            nav.isRootアListアVesselEditアEmoji = nil
            var results = self.keyPathsForNonNilAndTrueProperties(nav)
            switch state {
            case .rootアListアVesselEditアReminderEdit, .rootアListアVesselEditアEmoji, .rootアListアVesselEdit:
                results.subtract([\.isRootアListアVesselEdit])
            default:
                results.subtract([\.isRootアList])
            }
            XCTAssertEqual(results.count, 0)
        }
    }
    
    func test_case_reset_listSettings() {
        for state in Navigation.State.TEST_allCases {
            var nav = Navigation(state)
            nav.isRootアListアSettings = false
            var results = self.keyPathsForNonNilAndTrueProperties(nav)
            results.subtract([\.isRootアList])
            XCTAssertEqual(results.count, 0)
        }
    }
    
    func test_case_reset_listError() {
        for state in Navigation.State.TEST_allCases {
            var nav = Navigation(state)
            nav.isRootアError = false
            var results = self.keyPathsForNonNilAndTrueProperties(nav)
            results.subtract([\.isRootアList])
            XCTAssertEqual(results.count, 0)
        }
    }
    
    // MARK: Helpers
    
    private typealias NavKP = PartialKeyPath<Navigation>
    private func keyPathsForNonNilAndTrueProperties(_ nav: Navigation) -> Set<NavKP> {
        var kps: Set<NavKP> = []
        if nav.isRootアList == true {
            kps.insert(\.isRootアList)
        }
        if nav.isRootアError == true {
            kps.insert(\.isRootアError)
        }
        if nav.isRootアListアMenu == true {
            kps.insert(\.isRootアListアMenu)
        }
        if nav.isRootアListアMenuData != nil {
            kps.insert(\.isRootアListアMenuData)
        }
        if nav.isRootアListアWatering != nil {
            kps.insert(\.isRootアListアWatering)
        }
        if nav.isRootアListアSummary != nil {
            kps.insert(\.isRootアListアSummary)
        }
        if nav.isRootアListアReminderEdit != nil {
            kps.insert(\.isRootアListアReminderEdit)
        }
        if nav.isRootアListアVesselEdit != nil {
            kps.insert(\.isRootアListアVesselEdit)
        }
        if nav.isRootアListアVesselEditアReminderEdit != nil {
            kps.insert(\.isRootアListアVesselEditアReminderEdit)
        }
        if nav.isRootアListアVesselEditアEmoji != nil {
            kps.insert(\.isRootアListアVesselEditアEmoji)
        }
        if nav.isRootアListアSettings == true {
            kps.insert(\.isRootアListアSettings)
        }
        if nav.isRootアListアError == true {
            kps.insert(\.isRootアListアError)
        }
        
        // Will cause compile failure when ENUM changes
        switch Navigation.State.rootアList {
        case .rootアError: break
        case .rootアList: break
        case .rootアListアError: break
        case .rootアListアSettings: break
        case .rootアListアMenu(_): break
        case .rootアListアWatering(_): break
        case .rootアListアSummary(_): break
        case .rootアListアReminderEdit(_): break
        case .rootアListアVesselEdit(_): break
        case .rootアListアVesselEditアReminderEdit(_): break
        case .rootアListアVesselEditアEmoji(_): break
        }
        return kps
    }
}


extension Navigation.State {
    
    static let TEST_reminderID = Reminder.アイディ("ABC123")
    static let TEST_vesselID = Vessel.アイディ("DEF456")
    static let TEST_rootList: Navigation.State = .rootアList
    static let TEST_rootError: Navigation.State = .rootアError
    static let TEST_listMenu: Navigation.State = .rootアListアMenu(.init(TEST_reminderID, TEST_vesselID))
    static let TEST_listWatering: Navigation.State = .rootアListアWatering(.init([TEST_reminderID]))
    static let TEST_listSummary: Navigation.State = .rootアListアSummary(.init(TEST_reminderID))
    static let TEST_listReminderEdit: Navigation.State = .rootアListアReminderEdit(.init(TEST_reminderID))
    static let TEST_listVesselEdit: Navigation.State = .rootアListアVesselEdit(.init(TEST_vesselID))
    static let TEST_listVesselEditReminderEdit: Navigation.State = .rootアListアVesselEditアReminderEdit(.init(TEST_reminderID, TEST_vesselID))
    static let TEST_listVesselEditEmoji: Navigation.State = .rootアListアVesselEditアEmoji(.init(TEST_vesselID))
    static let TEST_listSettings: Navigation.State = .rootアListアSettings
    static let TEST_listError: Navigation.State = .rootアListアError
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
