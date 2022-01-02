//
//  Created by Jeffrey Bergier on 2022/01/02.
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
import Nav
import Datum

internal struct VesselEmoji: View {
    
    @Nav private var nav
    @VesselEditQuery private var vessel: Vessel
    
    internal init(id: Vessel.アイディ, controller: AnyController) {
        _vessel = VesselEditQuery(id: id, controller: controller)
    }
    
    internal var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.fixed(64)),
                                    GridItem(.adaptive(minimum: 64, maximum: 64))])
                {
                    ForEach(Model.VesselEmoji) { item in
                        Button {
                            self.vessel.icon = .emoji(item)
                            self.nav.state = .listVesselEdit(.init(self.vessel.id))
                        } label: {
                            ZStack {
                                if self.vessel.icon?.emoji == item {
                                    Color.accentColor
                                }
                                Text(item).font(Font.largeTitle)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Choose an Emoji")
            .toolbar {
                Button("Done") { self.nav.state = .listVesselEdit(.init(self.vessel.id)) }
            }
        }
    }
}
