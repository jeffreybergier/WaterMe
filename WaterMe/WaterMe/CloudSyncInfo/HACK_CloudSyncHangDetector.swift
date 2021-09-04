//
//  HACK_CloudSyncHangDetector.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 2021/09/04.
//  Copyright © 2021 Saturday Apps. All rights reserved.
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

import Datum
import Calculate
import Combine
import Foundation

// AnyContinousProgress<GenericInitializationError, CloudKitSyncError>

class HACK_CloudSyncHangDetector {
    
    private let onHangClosure: () -> Void
    private var token: Any?
    private var timer: Timer?
    
    private let progressChangedClosure: (HACK_CloudSyncHangDetector, Progress) -> Void = { detector, progress in
        "Progress: \(progress.fractionCompleted)%".log(as: .debug)
        switch progress.fractionCompleted {
        case 1, 0:
            "Timer: Cancelled".log(as: .debug)
            detector.cancelTimer()
        default:
            "Timer: Started".log(as: .debug)
            detector.resetTimer()
        }
    }
    
    init?(result: Result<BasicController, DatumError>, onHang: @escaping () -> Void) {
        guard #available(iOS 14.0, *) else { return nil }
        guard
            case .success(let controller) = result,
            let progress = controller.syncProgress
        else { return nil }
        self.onHangClosure = onHang
        self.token = progress.objectWillChange.sink { [weak self, weak progress] in
            guard let progress = progress, let self = self else { return }
            // need to wait for a split second because
            // this is objectWillChange (not did change)
            DispatchQueue.main.async {
                self.progressChangedClosure(self, progress.progress)
            }
        }
    }
    
    @available(iOS 13.0, *)
    init(progress: AnyContinousProgress<GenericInitializationError, CloudKitSyncError>, onHang: @escaping () -> Void) {
        self.onHangClosure = onHang
        self.token = progress.objectWillChange.sink { [weak self, weak progress] in
            guard let progress = progress, let self = self else { return }
            // need to wait for a split second because
            // this is objectWillChange (not did change)
            DispatchQueue.main.async {
                self.progressChangedClosure(self, progress.progress)
            }
        }
    }
    
    private func cancelTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    private func resetTimer() {
        self.cancelTimer()
        self.timer = Timer.scheduledTimer(timeInterval: 3,
                                          target: self,
                                          selector: #selector(self.timerFired(_:)),
                                          userInfo: nil,
                                          repeats: true)
    }
    
    @objc private func timerFired(_ timer: Timer) {
        "NSPersistentCloudKitContainer RESET due to HANG".log(as: .severe)
        self.cancelTimer()
        if #available(iOS 13.0, *) {
            (self.token as? AnyCancellable)?.cancel()
        }
        self.token = nil
        self.onHangClosure()
    }
    
    deinit {
        self.timer?.invalidate()
        self.timer = nil
    }
    
}
