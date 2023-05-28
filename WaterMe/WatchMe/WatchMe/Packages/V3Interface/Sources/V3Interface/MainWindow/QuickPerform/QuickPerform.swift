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

internal struct QuickPerform: View {
    
    @ReminderListQuery(.late)     private var late
    @ReminderListQuery(.today)    private var today
    @ReminderListQuery(.tomorrow) private var tomorrow
    
    private let id: Share.Identifier
    
    internal init(_ id: Share.Identifier) {
        self.id = id
    }
    
    internal var body: some View {
        ScrollView {
            Text("Late: \(self.late.data.count)")
            Text("Today: \(self.today.data.count)")
            Text("Tomorrow: \(self.tomorrow.data.count)")
            Text("View All")
        }
        .onLoadChange(of: self.id) {
            self.late.filter     = .share($0)
            self.today.filter    = .share($0)
            self.tomorrow.filter = .share($0)
        }
    }
}
