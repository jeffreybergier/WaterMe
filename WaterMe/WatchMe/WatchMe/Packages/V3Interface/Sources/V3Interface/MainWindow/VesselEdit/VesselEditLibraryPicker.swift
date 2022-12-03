//
//  Created by Jeffrey Bergier on 2022/12/03.
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

extension VesselEdit {
    internal struct LibraryPicker: View {
        
        @VesselQuery private var vessel
        
        @V3Style.VesselEdit.LibraryPicker private var style
        @V3Localize.VesselEdit.LibraryPicker private var text
        
        private let id: Vessel.Selection.Element
        
        internal init(id: Vessel.Selection.Element) {
            self.id = id
        }
        
        internal var body: some View {
            Text("Library")
                .navigationTitle(self.text.title)
                .onLoadChange(of: self.id) {
                    _vessel.setIdentifier($0)
                }
        }
    }
}
