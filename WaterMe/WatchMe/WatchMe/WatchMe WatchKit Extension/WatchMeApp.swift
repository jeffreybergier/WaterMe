//
//  Created by Jeffrey Bergier on 2021/12/30.
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

@main
struct WatchMeApp: App {
    
    @State private var nav = Nav.reminderList(.none)
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                self.render()
            }
        }
    }
    
    @ViewBuilder private func render() -> some View {
        switch self.nav {
        case .reminderList(let presentation):
            switch presentation {
            case .none: // Show main screen
                ContentView()
            case .summary: // show reminder summary screen
                ContentView()
            case .plant: // show plant edit screen
                ContentView()
            case .reminder: // show reminder edit screen
                ContentView()
            case .settings: // show settings screen
                ContentView()
            case .error: // show an error
                ContentView()
            }
        }
    }
}
