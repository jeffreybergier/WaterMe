//
//  Created by Jeffrey Bergier on 2022/11/12.
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

internal struct VesselGrid: View {
    
    @VesselListQuery private var query
    @Binding private var nav: V3Nav.VesselGrid
    private let id: Share.Identifier
    
    internal init(_ id: Share.Identifier, nav: Binding<V3Nav.VesselGrid>) {
        self.id = id
        _nav = nav
    }
    
    internal var body: some View {
        self.query.data.view { item in
            List {
                Section {
                    
                } header: {
                    
                }
            }
        } onEmpty: {
            Text("Loading...")
        }
        .navigationTitle("Edit Plant")
        .onLoadChange(of: self.id) {
            self.query.filter = .share($0)
        }
    }
}
