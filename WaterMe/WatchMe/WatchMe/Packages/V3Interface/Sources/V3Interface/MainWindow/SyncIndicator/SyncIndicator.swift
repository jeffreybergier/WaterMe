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
import Umbrella
import V3Style
import V3Localize
import V3Datum

internal struct SyncIndicator: ViewModifier {
    
    @ErrorStorage private var errors
    @StateObject private var observer = SyncObserver()
    @EnvironmentObject private var syncProgress: ContinousProgress.Environment
    
    @V3Localize.SyncIndicator private var text
    
    // TODO: Get rid of timer and hook up to real data
    @State private var timer = Timer.publish(every: 2.0, on: .main, in: .default).autoconnect()
    @State private var state = V3Style.SyncIndicator.Visibility.idle
    
    internal init() { }
    
    internal func body(content: Content) -> some View {
        ZStack {
            content
            self.syncIndicator
        }
        .onChange(of: self.syncProgress.id) { _ in
            self.observer.progress = self.syncProgress.value.progress
            self.observer.newestError = self.syncProgress.value.errors.first
        }
    }
    
    private var syncIndicator: V3Style.SyncIndicator {
        .init(state: self.observer.visibility, configuration: self.configuration) {
            switch $0 {
            case .idle, .syncing, .idleSoon:
                assertionFailure()
            case .error, .unavailable:
                let errors = self.syncProgress.value.errors
                guard errors.isEmpty == false else { return }
                self.syncProgress.value.errors = []
                errors.forEach(self.errors.append(_:))
            }
        }
    }
    
    private var configuration: V3Style.SyncIndicator.Localization {
        .init(idle: self.text.idle,
              error: self.text.error,
              unavailable: self.text.unavailable,
              syncing: self.text.syncing,
              idleSoon: self.text.idleSoon)
    }
}

private class SyncObserver: ObservableObject {
    
    @Published internal var visibility: V3Style.SyncIndicator.Visibility = .idle
    
    internal var newestError: Swift.Error? {
        didSet {
            self.updateVisibility()
        }
    }
    
    internal var progress: Progress? {
        didSet {
            self.updateVisibility()
        }
    }
    
    internal func updateVisibility() {
        if let newestError {
            if newestError is Umbrella.CPAccountStatus {
                self.visibility = .unavailable
            } else {
                self.visibility = .error
            }
            return
        }
        
        if let progress, progress.fractionCompleted < 1.0 {
            self.visibility = .syncing
        } else {
            self.visibility = .idle
        }
    }
    
}
