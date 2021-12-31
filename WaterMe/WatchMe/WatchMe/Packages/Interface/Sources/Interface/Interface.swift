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
import Nav
import Datum

public struct Interface: View {

    @State private var nav = Nav.reminderList(.none)
    @StateObject private var controller = try! CD_Controller(kind: .local)
    
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
        case .reminderList(let presentation):
            switch presentation {
            case .none: // Show main screen
                ReminderList()
            case .summary: // show reminder summary screen
                Text("// TODO: Summary")
            case .plant: // show plant edit screen
                Text("// TODO: Plant Edit")
            case .reminder: // show reminder edit screen
                Text("// TODO: Reminder Edit")
            case .settings: // show settings screen
                Text("// TODO: Settings")
            case .error: // show an error
                Text("// TODO: Error")
            }
        }
    }
}
