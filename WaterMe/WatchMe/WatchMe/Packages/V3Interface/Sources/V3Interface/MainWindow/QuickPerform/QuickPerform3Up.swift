//
//  Created by Jeffrey Bergier on 2023/07/09.
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

#if os(watchOS)

import SwiftUI
import Umbrella
import V3Model
import V3Datum
import V3Style
import V3Localize

internal struct QuickPerform3Up: View {
    
    @V3Style.QuickPerform private var style
    @V3Localize.QuickPerform private var text
    
    @ReminderQuery private var reminder0
    @ReminderQuery private var reminder1
    @ReminderQuery private var reminder2
    
    @VesselQuery private var vessel0
    @VesselQuery private var vessel1
    @VesselQuery private var vessel2
    
    private var display0: V3Style.QuickPerform.IconRequest? {
        .init(reminder: self.reminder0.data,
              vessel: self.vessel0.data,
              localize: self.text)
    }
    
    private var display1: V3Style.QuickPerform.IconRequest? {
        .init(reminder: self.reminder1.data,
              vessel: self.vessel1.data,
              localize: self.text)
    }
    
    private var display2: V3Style.QuickPerform.IconRequest? {
        .init(reminder: self.reminder2.data,
              vessel: self.vessel2.data,
              localize: self.text)
    }
    
    private let upTo3IDs: Set<Reminder.Identifier>
    private let totalIDs: Int
    
    private var extra: Int? {
        guard self.totalIDs > self.upTo3IDs.count else { return nil }
        return self.totalIDs - self.upTo3IDs.count
    }
    
    internal init(upTo3IDs: Set<Reminder.Identifier>, totalIDs: Int) {
        assert(upTo3IDs.isEmpty == false)
        assert(upTo3IDs.count <= 3)
        self.upTo3IDs = upTo3IDs
        self.totalIDs = totalIDs
    }
    
    internal var body: some View {
        // TODO: Not sure why this HStack is needed
        HStack {
            self.style.threeUpIcon(self.display0,
                                   self.display1,
                                   self.display2,
                                   self.extra)
        }
        .onChange(of: self.upTo3IDs, initial: true) { _, identifiers in
            var identifiers = identifiers
            self.reminder0.identifier = identifiers.popFirst()
            self.reminder1.identifier = identifiers.popFirst()
            self.reminder2.identifier = identifiers.popFirst()
        }
        .onChange(of: self.reminder0.data) { _, newValue in
            self.vessel0.identifier = newValue?.vesselID
        }
        .onChange(of: self.reminder1.data) { _, newValue in
            self.vessel1.identifier = newValue?.vesselID
        }
        .onChange(of: self.reminder2.data) { _, newValue in
            self.vessel2.identifier = newValue?.vesselID
        }
    }
}

extension V3Style.QuickPerform.IconRequest {
    fileprivate init?(reminder: Reminder?,
                      vessel: Vessel?,
                      localize: V3Localize.QuickPerform.Value)
    {
        guard
            let reminder = reminder,
            let vessel = vessel
        else { return nil }
        let kind: ActionLocalization
        switch reminder.kind {
        case .water:     kind = localize.kindWater
        case .fertilize: kind = localize.kindFertilize
        case .trim:      kind = localize.kindTrim
        case .mist:      kind = localize.kindMist
        case .move:      kind = localize.kindMove
        case .other:     kind = localize.kindOther
        }
        self.init(vesselIconImage: vessel.icon?.imageValue,
                  vesselIconEmoji: vessel.icon?.stringValue,
                  reminderKind: kind)
    }
}

#endif
