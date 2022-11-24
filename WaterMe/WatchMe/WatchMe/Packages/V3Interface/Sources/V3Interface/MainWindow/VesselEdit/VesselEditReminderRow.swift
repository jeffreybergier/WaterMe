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
        
        @V3Style.VesselEdit private var style
        @V3Localize.VesselEdit private var text
                
        @ReminderQuery private var reminder
        private let id: Reminder.Identifier
        private let action: () -> Void
        
        internal init(_ id: Reminder.Identifier, action: @escaping () -> Void) {
            self.id = id
            self.action = action
        }
        
        internal var body: some View {
            self.reminder.view { reminder in
                self.style.row(subtitle: self.text.interval(reminder.interval))
                          .action(text: self.text(for: reminder.kind))
                          .button(action: self.action)
            } onNIL: {
                self.style.fallback
                          .action(text: self.text.notFound)
                          .label
            }
            .onLoadChange(of: self.id) {
                _reminder.setIdentifier($0)
            }
        }
        
        private func text(for kind: Reminder.Kind) -> ActionLocalization {
            switch kind {
            case .water:
                return self.text.kindWater
            case .fertilize:
                return self.text.kindFertilize
            case .trim:
                return self.text.kindTrim
            case .mist:
                return self.text.kindMist
            case .move:
                return self.text.kindMove
            case .other:
                return self.text.kindOther
            }
        }
    }
}
