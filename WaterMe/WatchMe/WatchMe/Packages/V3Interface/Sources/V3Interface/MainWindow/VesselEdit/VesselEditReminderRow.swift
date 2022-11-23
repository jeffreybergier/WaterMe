//
//  Created by Jeffrey Bergier on 2022/11/23.
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
import V3Nav
import V3Model
import V3Datum
import V3Style
import V3Localize

extension VesselEdit {
    internal struct ReminderRow: View {
        
        @Nav private var nav
        @V3Style.VesselEdit private var style
        @V3Localize.VesselEdit private var text
        
        @Environment(\.errorResponder) private var errorResponder
        
        @ReminderQuery private var reminder
        
        private let id: Reminder.Identifier
        
        internal init(_ id: Reminder.Identifier) {
            self.id = id
        }
        
        internal var body: some View {
            self.reminder.view { reminder in
                self.style.row(image: JSBImage(systemName: "plus")!,
                               title: reminder.kind.rawValue,
                               subtitle: String(describing: reminder.interval))
            } onNIL: {
                self.style.fallback
                    .action(text: self.text.notFound)
                    .label
            }
            .onLoadChange(of: self.id) {
                _reminder.setIdentifier($0)
            }
        }
    }
}
