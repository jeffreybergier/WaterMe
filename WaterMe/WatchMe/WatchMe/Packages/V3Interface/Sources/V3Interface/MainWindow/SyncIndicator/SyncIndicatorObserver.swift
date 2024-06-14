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

import Combine
import SwiftUI
import Umbrella
import V3Style

@MainActor
internal class SyncIndicatorObserver: ObservableObject {
    
    @Published private(set) internal var visibility: V3Style.SyncIndicator.Visibility = .idle
    private var cancellable: AnyCancellable?
    private var idleTimer: Timer?
    
    internal var newestError: Swift.Error? {
        didSet {
            self.updateVisibility()
        }
    }
    
    internal var progress: Progress? {
        didSet {
            self.cancellable?.cancel()
            self.cancellable = self.progress?.publisher(for: \.fractionCompleted).sink { [weak self] _ in
                self?.updateVisibility()
            }
        }
    }
    
    internal func updateVisibility() {
        if let newestError {
            if newestError is Umbrella.CPAccountStatus {
                self.visibility = .unavailable
            } else {
                self.visibility = .error
            }
        } else if let fractionCompleted = self.progress?.fractionCompleted {
            switch fractionCompleted {
            case 0, 1:
                guard self.visibility != .idle else { return }
                self.visibility = .idleSoon
                self.configureIdleTimer()
            default:
                self.visibility = .syncing
            }
        } else {
            self.visibility = .idle
        }
    }
    
    private func configureIdleTimer() {
        self.idleTimer?.invalidate()
        self.idleTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] timer in
            timer.invalidate()
            MainActor.assumeIsolated {
                self?.idleTimer?.invalidate()
                self?.idleTimer = nil
                guard let self, case .idleSoon = self.visibility else { return }
                self.visibility = .idle
            }
        }
    }
}
