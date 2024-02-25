//
//  Created by Jeffrey Bergier on 2022/11/06.
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

internal struct ShareList: View {
    
    @V3Style.ShareList private var style
    @V3Localize.ShareList private var text
    
    @Nav private var nav
    @ShareListQuery private var data
    
    internal init() { }
    
    internal var body: some View {
        self.data.view {
            List($0, id: \.self, selection: self.$nav.detail.isPresented) {
                Row($0)
            }
        } onEmpty: {
            self.text.noContent.action(style: self.style.row).label
        }
        .navigationTitle(self.text.title)
    }
}
