//
//  Created by Jeffrey Bergier on 2023/05/01.
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
import AVKit
import AVFoundation
import V3Nav

internal struct WateringAnimation: View {
    
    @Nav private var nav
    
    @State private var player = AVPlayer(
        url: Bundle.module.url(forResource: "WateringLandscape",
                               withExtension: "mov")!
    )
    
    internal var body: some View {
        VideoPlayer(player: self.player)
            .ignoresSafeArea()
            .onAppear {
                self.player.seek(to: .zero)
                self.player.play()
            }
    }
    
//    switch self.controller.appendNewPerformToReminders(with: [reminder.id]) {
//    case .success:
//        self.nav.stack.pop()
//    case .failure(let error):
//        self.errors.append(error)
//    }
    
}
