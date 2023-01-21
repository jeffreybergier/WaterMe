//
//  Created by Jeffrey Bergier on 2022/11/06.
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

extension VesselList {
    internal struct Row: View {
        
        @VesselQuery private var query
        private let id: Vessel.Identifier
        
        internal init(_ id: Vessel.Identifier) {
            self.id = id
        }
        
        internal var body: some View {
            self.query.data.view { item in
                Text(item.kind.rawValue)
            } onNIL: {
                Text("Loading...") // TODO: Create empty states
            }
            .onLoadChange(of: self.id) {
                self.query.id = $0
            }
        }
    }
}
