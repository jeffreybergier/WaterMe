//
//  Created by Jeffrey Bergier on 2022/11/05.
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

import SwiftUI
import Umbrella
import V3Model
import V3Nav

internal struct MainWindow: View {
    
    @Nav private var nav
    
    internal init() { }
    
    internal var body: some View {
        NavigationSplitView {
            ShareList()
        } detail: {
            #if os(watchOS)
            if let share = self.nav.root.isPresented {
                QuickPerform(share, nav: self.$nav.root)
            } else {
                Text("// TODO: No Selection")
            }
            #else
            if let share = self.nav.root.isPresented {
                ReminderGrid(share, nav: self.$nav.root)
            } else {
                Text("// TODO: No Selection")
            }
            #endif

        }
        .modifier(SyncIndicator())
        .modifier(
            ErrorStorage.Presenter(
                isAlreadyPresenting: self.nav.isAlreadyPresenting,
                toPresent: self.$nav.isError,
                router: errorRouter(_:)
            )
        )
    }
}
