//
//  Created by Jeffrey Bergier on 2023/05/05.
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
import V3Style
import V3Localize

internal struct SyncIndicator: ViewModifier {
    
    @V3Localize.SyncIndicator private var text
    
    internal init() { }
    
    internal func body(content: Content) -> some View {
        ZStack {
            content
            V3Style.SyncIndicator(state: .error,
                                  configuration: self.configuration)
            {
                print($0)
            }
            .ignoresSafeArea()
        }
    }
    
    private var configuration: V3Style.SyncIndicator.Localization {
        .init(idle: self.text.idle,
              error: self.text.error,
              syncing: self.text.syncing,
              idleSoon: self.text.idleSoon)
    }
}
