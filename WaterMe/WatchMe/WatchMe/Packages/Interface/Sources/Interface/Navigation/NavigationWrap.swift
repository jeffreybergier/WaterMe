//
//  Created by Jeffrey Bergier on 2022/01/01.
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

import Datum

extension Navigation {
    internal struct Wrap {
        internal var value: Navigation
        internal var isMenu: Bool = false
        internal var isMenuData: ReminderList.Menu.Input? // TODO: Hack for confirmationDialog
        internal var isWatering: Bool = false
        internal var isSummary: Reminder.アイディ?
        internal var isReminder: Reminder.アイディ?
        internal var isPlant: Vessel.アイディ?
        internal var isSettings: Bool = false
        internal var isError: Bool = false
        
        internal init(_ nav: Navigation) {
            self.value = nav
            switch nav {
            case .list(let next):
                switch next {
                case .none:
                    break
                case .menu(let v):
                    self.isMenu = true
                    self.isMenuData = v
                case .watering:
                    self.isWatering = true
                case .summary(let v):
                    self.isSummary = v
                case .reminder(let v):
                    self.isReminder = v
                case .plant(let v):
                    self.isPlant = v
                case .settings:
                    self.isSettings = true
                case .error:
                    self.isError = true
                }
            }
        }
    }
}
