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
    
    private var display0: Display? {
        guard
            let reminder = self.reminder0.data,
            let vessel = self.vessel0.data
        else { return nil }
        return .init(name: vessel.displayName,
                     kind: reminder.kind,
                     image: vessel.icon)
    }
    
    private var display1: Display? {
        guard
            let reminder = self.reminder1.data,
            let vessel = self.vessel1.data
        else { return nil }
        return .init(name: vessel.displayName,
                     kind: reminder.kind,
                     image: vessel.icon)
    }
    
    private var display2: Display? {
        guard
            let reminder = self.reminder2.data,
            let vessel = self.vessel2.data
        else { return nil }
        return .init(name: vessel.displayName,
                     kind: reminder.kind,
                     image: vessel.icon)
    }
    
    private let upTo3IDs: Set<Reminder.Identifier>
    private let totalIDs: Int
    
    internal init(upTo3IDs: Set<Reminder.Identifier>, totalIDs: Int) {
        assert(upTo3IDs.isEmpty == false)
        assert(upTo3IDs.count <= 3)
        self.upTo3IDs = upTo3IDs
        self.totalIDs = totalIDs
    }
    
    @ViewBuilder private var threeUpDisplay: some View {
        if let display0, let display1, let display2 {
            VStack(spacing: -16) {
                HStack(spacing: -8) {
                    self.style.icon(image: display0.image?.imageValue,
                                    emoji: display0.image?.stringValue)
                    self.style.icon(image: display1.image?.imageValue,
                                    emoji: display1.image?.stringValue)
                }
                self.style.icon(image: display2.image?.imageValue,
                                emoji: display2.image?.stringValue)
            }
        } else if let display0, let display1 {
            HStack(spacing: -8) {
                self.style.icon(image: display0.image?.imageValue,
                                emoji: display0.image?.stringValue)
                self.style.icon(image: display1.image?.imageValue,
                                emoji: display1.image?.stringValue)
            }
        } else if let display0 {
            self.style.icon(image: display0.image?.imageValue,
                            emoji: display0.image?.stringValue)
        }
    }
    
    internal var body: some View {
        // TODO: Not sure why this HStack is needed
        HStack {
            VStack {
                self.threeUpDisplay
                if self.totalIDs > 3 {
                    Text("+ \(self.totalIDs - 3) more…")
                }
            }
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

private struct Display {
    internal var name: String?
    internal var kind: Reminder.Kind
    internal var image: Vessel.Icon?
}
