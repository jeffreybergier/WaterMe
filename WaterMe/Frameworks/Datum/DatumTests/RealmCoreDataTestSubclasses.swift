//
//  RealmCoreDataTestSubclasses.swift
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

@testable import DatumL

class RLM_ReminderCollectionTests: ReminderCollectionTests {
    override func newBasicController() -> BasicController {
        return try! testing_NewRLMBasicController().get()
    }
}

class CD_ReminderCollectionTests: ReminderCollectionTests {
    override func newBasicController() -> BasicController {
        return try! testing_NewCDBasicController().get()
    }
}

class RLM_ReminderVesselCollectionTests: ReminderVesselCollectionTests {
    override func newBasicController() -> BasicController {
        return try! testing_NewRLMBasicController().get()
    }
}

class CD_ReminderVesselCollectionTests: ReminderVesselCollectionTests {
    override func newBasicController() -> BasicController {
        return try! testing_NewCDBasicController().get()
    }
}

class RLM_GroupedReminderCollectionTests: GroupedReminderCollectionTests {
    override func newBasicController() -> BasicController {
        return try! testing_NewRLMBasicController().get()
    }
}

class CD_GroupedReminderCollectionTests: GroupedReminderCollectionTests {
    override func newBasicController() -> BasicController {
        return try! testing_NewCDBasicController().get()
    }
}

class RLM_BasicControllerReadTests: BasicControllerReadTests {
    override func newBasicController() -> BasicController {
        return try! testing_NewRLMBasicController().get()
    }
}

class CD_BasicControllerReadTests: BasicControllerReadTests {
    override func newBasicController() -> BasicController {
        return try! testing_NewCDBasicController().get()
    }
}

class RLM_BasicControllerCreateUpdateTests: BasicControllerCreateUpdateTests {
    override func newBasicController() -> BasicController {
        return try! testing_NewRLMBasicController().get()
    }
}

class CD_BasicControllerCreateUpdateTests: BasicControllerCreateUpdateTests {
    override func newBasicController() -> BasicController {
        return try! testing_NewCDBasicController().get()
    }
}

class RLM_BasicControllerDeleteTests: BasicControllerDeleteTests {
    override func newBasicController() -> BasicController {
        return try! testing_NewRLMBasicController().get()
    }
}

class CD_BasicControllerDeleteTests: BasicControllerDeleteTests {
    override func newBasicController() -> BasicController {
        return try! testing_NewCDBasicController().get()
    }
}

class RLM_ReminderVesselTests: ReminderVesselTests {
    override func newBasicController() -> BasicController {
        return try! testing_NewRLMBasicController().get()
    }
}

class CD_ReminderVesselTests: ReminderVesselTests {
    override func newBasicController() -> BasicController {
        return try! testing_NewCDBasicController().get()
    }
}

class RLM_ReminderTests: ReminderTests {
    override func newBasicController() -> BasicController {
        return try! testing_NewRLMBasicController().get()
    }
}

class CD_ReminderTests: ReminderTests {
    override func newBasicController() -> BasicController {
        return try! testing_NewCDBasicController().get()
    }
}

class RLM_ReminderPerformTests: ReminderPerformTests {
    override func newBasicController() -> BasicController {
        return try! testing_NewRLMBasicController().get()
    }
}

class CD_ReminderPerformTests: ReminderPerformTests {
    override func newBasicController() -> BasicController {
        return try! testing_NewCDBasicController().get()
    }
}

class RLM_BasicControllerClosureTests: BasicControllerClosureTests {
    override func newBasicController() -> BasicController {
        return try! testing_NewRLMBasicController().get()
    }
}

class CD_BasicControllerClosureTests: BasicControllerClosureTests {
    override func newBasicController() -> BasicController {
        return try! testing_NewCDBasicController().get()
    }
}
