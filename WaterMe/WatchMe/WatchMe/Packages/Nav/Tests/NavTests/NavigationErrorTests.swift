//
//  Created by Jeffrey Bergier on 2022/02/06.
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
@testable import Nav
import Errors
import Datum
import Model

let error1 = CameraPermissionError.cameraRestricted
let error2 = CameraPermissionError.cameraDenied
let error3 = CameraPermissionError.libraryIncapable
let error4 = CameraPermissionError.cameraIncapable
let error5 = Datum.Error.load
let error6 = Datum.Error.cannotDeleteLastReminder
let error7 = Datum.Error.maintenanceDeleteOrphanedReminders

let vID1 = Vessel.アイディ("VID1")
let vID2 = Vessel.アイディ("VID2")
let vID3 = Vessel.アイディ("VID3")
let vID4 = Vessel.アイディ("VID4")
let vID5 = Vessel.アイディ("VID5")
let vID6 = Vessel.アイディ("VID6")
let vID7 = Vessel.アイディ("VID7")

let rID1 = Reminder.アイディ("RID1")
let rID2 = Reminder.アイディ("RID2")
let rID3 = Reminder.アイディ("RID3")
let rID4 = Reminder.アイディ("RID4")
let rID5 = Reminder.アイディ("RID5")
let rID6 = Reminder.アイディ("RID6")
let rID7 = Reminder.アイディ("RID7")

class NavigationErrorTests: XCTestCase {
    
    func test_navigationGeneric() {
        var nav = NavigationGeneric()
        XCTAssertNil(nav.isError)
        XCTAssertNil(nav.append(error1))
        XCTAssertEqual(nav.isError as! CameraPermissionError, error1)
        XCTAssertEqual(nav.append(error2) as! CameraPermissionError, error2)
        XCTAssertEqual(nav.isError as! CameraPermissionError, error1)
    }
    
    func test_navigationReminderList() {
        _ = {
            let nav = NavigationReminderList()
            XCTAssertNil(nav.isError)
            XCTAssertNil(nav.isSettings)
            XCTAssertNil(nav.isWatering)
            XCTAssertNil(nav.isSummary)
            XCTAssertNil(nav.isReminderEdit)
            XCTAssertNil(nav.isVesselEdit)
        }()
        _ = {
            var nav = NavigationReminderList()
            XCTAssertNil(nav.isError)
            XCTAssertNil(nav.append(error1))
            XCTAssertEqual(nav.isError as! CameraPermissionError, error1)
            XCTAssertEqual(nav.append(error2) as! CameraPermissionError, error2)
            XCTAssertEqual(nav.isError as! CameraPermissionError, error1)
        }()
        _ = {
            var nav = NavigationReminderList()
            nav.isSettings = ()
            XCTAssertEqual(nav.append(error1) as! CameraPermissionError, error1)
            XCTAssertNil(nav.isError)
        }()
        _ = {
            var nav = NavigationReminderList()
            nav.isWatering = .init([rID1])
            XCTAssertEqual(nav.append(error1) as! CameraPermissionError, error1)
            XCTAssertNil(nav.isError)
        }()
        _ = {
            var nav = NavigationReminderList()
            nav.isSummary = .init(rID1, vID1)
            XCTAssertEqual(nav.append(error1) as! CameraPermissionError, error1)
            XCTAssertNil(nav.isError)
        }()
        _ = {
            var nav = NavigationReminderList()
            nav.isReminderEdit = .init(rID1)
            XCTAssertEqual(nav.append(error1) as! CameraPermissionError, error1)
            XCTAssertNil(nav.isError)
        }()
        _ = {
            var nav = NavigationReminderList()
            nav.isVesselEdit = .init(vID1)
            XCTAssertEqual(nav.append(error1) as! CameraPermissionError, error1)
            XCTAssertNil(nav.isError)
        }()
    }
    
    func test_navigationReminderEdit() {
        var nav = NavigationReminderEdit()
        XCTAssertNil(nav.isError)
        XCTAssertNil(nav.append(error1))
        XCTAssertEqual(nav.isError as! CameraPermissionError, error1)
        XCTAssertEqual(nav.append(error2) as! CameraPermissionError, error2)
        XCTAssertEqual(nav.isError as! CameraPermissionError, error1)
    }
    
    func test_navigationVesselEdit() {
        _ = {
            let nav = NavigationVesselEdit()
            XCTAssertNil(nav.isError)
            XCTAssertNil(nav.isReminderEdit)
            XCTAssertNil(nav.isIconMenu)
            XCTAssertNil(nav.isIconEmoji)
            XCTAssertNil(nav.isIconCamera)
            XCTAssertNil(nav.isIconLibrary)
            XCTAssertNil(nav.isIconView)
        }()
        _ = {
            var nav = NavigationVesselEdit()
            XCTAssertNil(nav.isError)
            XCTAssertNil(nav.append(error1))
            XCTAssertEqual(nav.isError as! CameraPermissionError, error1)
            XCTAssertEqual(nav.append(error2) as! CameraPermissionError, error2)
            XCTAssertEqual(nav.isError as! CameraPermissionError, error1)
        }()
        _ = {
            var nav = NavigationVesselEdit()
            nav.isReminderEdit = .init(rID1)
            XCTAssertEqual(nav.append(error1) as! CameraPermissionError, error1)
            XCTAssertNil(nav.isError)
        }()
        _ = {
            var nav = NavigationVesselEdit()
            nav.isIconMenu = .init(vID1)
            XCTAssertEqual(nav.append(error1) as! CameraPermissionError, error1)
            XCTAssertNil(nav.isError)
        }()
        _ = {
            var nav = NavigationVesselEdit()
            nav.isIconEmoji = .init(vID1)
            XCTAssertEqual(nav.append(error1) as! CameraPermissionError, error1)
            XCTAssertNil(nav.isError)
        }()
        _ = {
            var nav = NavigationVesselEdit()
            nav.isIconCamera = .init(vID1)
            XCTAssertEqual(nav.append(error1) as! CameraPermissionError, error1)
            XCTAssertNil(nav.isError)
        }()
        _ = {
            var nav = NavigationVesselEdit()
            nav.isIconLibrary = .init(vID1)
            XCTAssertEqual(nav.append(error1) as! CameraPermissionError, error1)
            XCTAssertNil(nav.isError)
        }()
        _ = {
            var nav = NavigationVesselEdit()
            nav.isIconView = .init(vID1)
            XCTAssertEqual(nav.append(error1) as! CameraPermissionError, error1)
            XCTAssertNil(nav.isError)
        }()
    }
    
}

/*
class GENERIC_NavigationTests: XCTestCase {
    func test_navigationGeneric() {}
    func test_navigationReminderList() {}
    func test_navigationReminderEdit() {}
    func test_navigationVesselEdit() {}
}
*/
