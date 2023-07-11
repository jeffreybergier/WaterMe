//
//  Created by Jeffrey Bergier on 2023/05/27.
//
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
import V3Datum
import V3Nav
import V3Localize
import V3Style

internal struct QuickPerform: View {
    
    @V3Style.QuickPerform private var style
    @V3Localize.QuickPerform private var text
    
    private let id: Share.Identifier
    
    internal init(_ id: Share.Identifier) {
        self.id = id
    }
    
    internal var body: some View {
        TabView {
            QuickPerformTab(self.id, section: .late)
            QuickPerformTab(self.id, section: .today)
            QuickPerformTab(self.id, section: .tomorrow)
        }
        .tabViewStyle(.verticalPage)
        .navigationTitle(self.text.title)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()
                self.style.button.action(text: self.text.hamburger).button {
                    
                }
            }
        }
    }
    
    
}
