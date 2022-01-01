//
//  Created by Jeffrey Bergier on 2021/12/31.
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

import SwiftUI
import Datum

public struct Interface: View {

    @State private var nav = Nav.list(.none)
    @StateObject private var controller = NewController(of: .local)!
    
    public init() {}

    public var body: some View {
        NavigationView {
            self.render()
        }
        .environmentObject(self.controller)
        .environment(\.managedObjectContext, self.controller.__ENVONLY__managedObjectContext)
    }

    @ViewBuilder private func render() -> some View {
        switch self.nav {
        case .list(let presentation):
            switch presentation {
            case .none: // Show main screen
                ReminderList(nav: self.$nav)
            case .menu(let reminder): // Show the menu
                ReminderList(nav: self.$nav)
                    .modifier(ReminderList.Menu(nav: self.$nav, reminder: reminder))
            case .watering:
                ReminderList(nav: self.$nav)
                    .modifier(Watering.Pres(nav: self.$nav))
            case .summary: // show reminder summary screen
                Text("// TODO: Summary")
            case .plant(let uuid): // show plant edit screen
                ReminderList(nav: self.$nav)
                    .modifier(VesselEdit.Pres(uuid: uuid, nav: self.$nav))
            case .reminder(let uuid): // show reminder edit screen
                ReminderList(nav: self.$nav)
                    .modifier(ReminderEdit.Pres(uuid: uuid, nav: self.$nav))
            case .settings: // show settings screen
                Text("// TODO: Settings")
            case .error: // show an error
                Text("// TODO: Error")
            }
        }
    }
}
