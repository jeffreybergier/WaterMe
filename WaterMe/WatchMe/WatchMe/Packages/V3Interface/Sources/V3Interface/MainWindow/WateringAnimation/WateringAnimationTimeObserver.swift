//
//  Created by Jeffrey Bergier on 2023/05/04.
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
import AVFoundation

@MainActor
internal class WateringAnimationTimeObserver: ObservableObject {
    
    private var observerToken: Any? = nil
    private var timeoutTimer: Timer?
    private let timeoutInterval: TimeInterval = 0.3
    private let observeInterval = CMTime(
        seconds: 0.1,
        preferredTimescale: CMTimeScale(NSEC_PER_SEC)
    )
    
    @Published internal var videoEnded = false
    
    // TODO: Move this WateringLandscape String elsewhere
    internal let player = AVPlayer(
        url: Bundle.module.url(forResource: "WateringWatch",
                               withExtension: "mov")!
    )
    
    internal init() {
        self.configureObserver()
    }
    
    internal func playFromBeginning() {
        self.resetTimer()
        self.player.seek(to: .zero)
        self.player.play()
    }
    
    private func configureObserver() {
        self.observerToken = self.player.addPeriodicTimeObserver(forInterval: self.observeInterval,
                                                                 queue: nil)
        { [weak self] _ in
            MainActor.assumeIsolated {
                self?.resetTimer()
            }
        }
    }
    
    private func resetTimer() {
        self.videoEnded = false
        self.timeoutTimer?.invalidate()
        self.timeoutTimer = Timer.scheduledTimer(withTimeInterval: self.timeoutInterval,
                                                 repeats: false)
        { [weak self] timer in
            timer.invalidate()
            MainActor.assumeIsolated {
                self?.timeoutTimer = nil
                self?.videoEnded = true
            }
        }
    }
    
    deinit {
        MainActor.assumeIsolated {
            self.observerToken.map(self.player.removeTimeObserver(_:))
            self.timeoutTimer?.invalidate()
        }
    }
}
