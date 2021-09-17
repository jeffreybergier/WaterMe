//
//  Created by Jeffrey Bergier on 2021/01/28.
//
//  MIT License
//
//  Copyright (c) 2021 Jeffrey Bergier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import SwiftUI
import CoreData
import Combine
import CloudKit
import Collections

extension CKContainer {
    public class var sync_accountStatus: CKAccountStatus {
        var status: CKAccountStatus!
        let wait = DispatchSemaphore(value: 0)
        CKContainer.default().accountStatus { _status, _ in
            status = _status
            wait.signal()
        }
        wait.wait()
        return status
    }
}

// TODO: Replace this file with original from Umbrella library

// Highly inspired by
// https://github.com/ggruen/CloudKitSyncMonitor/blob/main/Sources/CloudKitSyncMonitor/SyncMonitor.swift

/// Shows continuous progress of CloudKit syncing via NSPersistentCloudKitContainer.
/// Note, this class is not tested because it relies on NSNotificationCenter and other singletons.
@available(iOS 14.0, OSX 11.0, *)
public class CloudKitContainerContinuousProgress: ContinousProgress {
    
    public var initializeError: GenericInitializationError?
    public let progress: Progress
    public var errorQ = Deque<CloudKitSyncError>()
    
    private let syncName = NSPersistentCloudKitContainer.eventChangedNotification
    private let accountName = Notification.Name.CKAccountChanged
    private var io: Set<UUID> = []
    
    /// If container is not NSPersistentCloudKitContainer this class never shows any progress.
    public init(_ container: NSPersistentContainer) {
        self.progress = .init(totalUnitCount: 0)
        self.progress.completedUnitCount = 0
        guard container is NSPersistentCloudKitContainer else {
            "CloudKitContainerContinuousProgress can only be show progress of sync with NSPersistentCloudKitContainer".log(as: .severe)
            return
        }
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(self.observeSync(_:)),
                       name: self.syncName,
                       object: container)
        nc.addObserver(self,
                       selector: #selector(self.observeAccount),
                       name: self.accountName,
                       object: nil)
        self.observeAccount()
    }
    
    @objc private func observeAccount() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
            self.initializeError = .init(rawValue: CKContainer.sync_accountStatus)
        }
    }
    
    @objc private func observeSync(_ aNotification: Notification) {
        let key = NSPersistentCloudKitContainer.eventNotificationUserInfoKey
        guard let event = aNotification.userInfo?[key]
                      as? NSPersistentCloudKitContainer.Event else { return }
        DispatchQueue.main.async {
            self.objectWillChange.send()
            if let error = event.error {
                let convertedError = CloudKitSyncError(error)
                // only report the original error to the server
                // if its an unknown error
                if case .unknown = convertedError.typed {
                    error.log()
                } else {
                    error.log(as: .info)
                }
                self.errorQ.append(convertedError)
            }
            if self.io.contains(event.identifier) {
                "- \(event.identifier)".log(as: .debug)
                self.io.remove(event.identifier)
                self.progress.completedUnitCount += 1
            } else {
                "+ \(event.identifier)".log(as: .debug)
                self.io.insert(event.identifier)
                self.progress.totalUnitCount += 1
            }
            "progress: \(self.progress.completedUnitCount) / \(self.progress.totalUnitCount)".log(as: .debug)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: self.syncName, object: nil)
        NotificationCenter.default.removeObserver(self, name: self.accountName, object: nil)
        Loggable.default?.verbose()
    }
}

