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
import Umbrella
import V3Nav
import V3Model
import V3Datum

internal struct WateringAnimation: View {
    
    @Nav private var nav
    @Controller private var controller
    @ErrorStorage private var errors
    
    @State private var didAppearOnce = false
    @StateObject private var player = AnimationTimeObserver()
    
    private let selection: Reminder.Selection
    
    internal init(_ selection: Reminder.Selection) {
        self.selection = selection
    }
    
    internal var body: some View {
        VideoPlayer(player: self.player.player)
            .ignoresSafeArea()
            .onAppear {
                guard self.didAppearOnce == false else { return }
                self.didAppearOnce = true
                self.player.playFromBeginning()
                let result = self.controller.appendNewPerformToReminders(with: self.selection)
                result.error.map(self.errors.append(_:))
            }
            .onChange(of: self.player.videoEnded) { ended in
                guard ended == true else { return }
                self.nav.stack.pop()
            }
    }
}

internal class AnimationTimeObserver: ObservableObject {
    
    private var observerToken: Any? = nil
    private var timeoutTimer: Timer?
    private let timeoutInterval: TimeInterval = 0.3
    private let observeInterval = CMTime(
        seconds: 0.1,
        preferredTimescale: CMTimeScale(NSEC_PER_SEC)
    )
    
    @Published internal var videoEnded = false
    
    internal let player = AVPlayer(
        url: Bundle.module.url(forResource: "WateringLandscape",
                               withExtension: "mov")!
    )
    
    internal init() {
        self.configureObserver()
        self.resetTimer()
    }
    
    internal func playFromBeginning() {
        self.player.seek(to: .zero)
        self.player.play()
    }
    
    private func configureObserver() {
        self.observerToken = self.player.addPeriodicTimeObserver(forInterval: self.observeInterval,
                                                                 queue: nil)
        { [weak self] _ in
            self?.resetTimer()
        }
    }
    
    private func resetTimer() {
        self.timeoutTimer?.invalidate()
        self.timeoutTimer = Timer.scheduledTimer(withTimeInterval: self.timeoutInterval,
                                                 repeats: false)
        { [weak self] timer in
            timer.invalidate()
            self?.timeoutTimer = nil
            self?.videoEnded = true
        }
    }
    
    deinit {
        self.observerToken.map(self.player.removeTimeObserver(_:))
        self.timeoutTimer?.invalidate()
    }
}
