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
import Model
import Datum
import Umbrella

extension ReminderList.Grid {
    internal struct Cell: View {
        
        var reminder: Reminder
        @VesselEditQuery var vessel: Vessel
        
        internal init(reminder: Reminder, controller: AnyController) {
            self.reminder = reminder
            _vessel = VesselEditQuery(reminder, controller: controller)
        }
        
        internal var body: some View {
            VStack {
                if let image = self.vessel.icon?.image {
                    Image(uiImage: image)
                } else {
                    JSBText("🌸", text: self.vessel.icon?.emoji)
                }
                JSBText("My Plant", text: self.vessel.displayName)
            }
        }
    }
}
