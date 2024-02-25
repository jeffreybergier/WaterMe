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

internal struct WateringAnimation: View {
    
    @State private var didAppearOnce = false
    @StateObject private var player = WateringAnimationTimeObserver()
    
    private let onAnimationCompletion: () -> Void
    
    internal init(_ onAnimationCompletion: @escaping () -> Void) {
        self.onAnimationCompletion = onAnimationCompletion
    }
    
    internal var body: some View {
        VideoPlayer(player: self.player.player)
            .ignoresSafeArea()
            .onAppear {
                guard self.didAppearOnce == false else { return }
                self.didAppearOnce = true
                self.player.playFromBeginning()
            }
            .onChange(of: self.player.videoEnded, initial: false) { _, ended in
                guard ended == true else { return }
                self.onAnimationCompletion()
            }
    }
}
