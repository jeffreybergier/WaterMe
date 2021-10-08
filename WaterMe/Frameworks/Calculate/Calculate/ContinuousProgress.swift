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

import Combine
import CoreData
import Collections
import CloudKit

// TODO: Replace this file with original from Umbrella library
public typealias ErrorQueue = Deque<UserFacingError>

/// Represents the progress of something that is long running and can produce
/// errors upon startup and errors while running. I use this to reflect the status
/// of NSPersistentCloudKitContainer sync. But its generic enough to be used for
/// many types of long-running / background processes.
/// Use `AnyContinousProgress` to get around AssociatedType compile errors.
@available(iOS 13.0, *)
public protocol ContinousProgress: ObservableObject {
    associatedtype InitializeError: Swift.Error
    associatedtype QueueError: Swift.Error
    /// Fixed error that only occurs on startup and doesn't change
    /// for the lifetime of the process.
    var initializeError: InitializeError? { get }
    var progress: Progress { get }
    /// When an error occurs, append it to the Queue.
    var errorQ: Deque<QueueError> { get set }
}

@available(iOS 13.0, *)
public class AnyContinousProgress<InitError: Swift.Error, QError: Swift.Error>: ContinousProgress {

    public let objectWillChange: ObservableObjectPublisher
    public var initializeError: InitError? { _initializeError() }
    public var progress: Progress { _progress() }
    public var errorQ: Deque<QError> {
        get { _errorQ_get() }
        set { _errorQ_set(newValue) }
    }

    private var _initializeError: () -> InitError?
    private var _progress: () -> Progress
    private var _errorQ_get: () -> Deque<QError>
    private var _errorQ_set: (Deque<QError>) -> Void

    public init<T: ContinousProgress>(_ progress: T) where
        T.ObjectWillChangePublisher == ObservableObjectPublisher,
        T.InitializeError == InitError,
        T.QueueError == QError
    {
        self.objectWillChange = progress.objectWillChange
        _initializeError      = { progress.initializeError }
        _progress             = { progress.progress }
        _errorQ_get           = { progress.errorQ }
        _errorQ_set           = { progress.errorQ = $0 }
    }
}

/// Use when you have no progress to report
public class NoContinousProgress: ContinousProgress {
    public let initializeError: Swift.Error? = nil
    public let progress: Progress = .init()
    public var errorQ: Deque<Swift.Error> = .init()
    public init() {}
}

public enum GenericInitializationError: Swift.Error, RawRepresentable {

    case couldNotDetermine
    case restricted
    case noPassword
    case noAccount

    public init?(rawValue: CKAccountStatus) {
        switch rawValue {
        case .available:
            return nil
        case .restricted:
            self = .restricted
        case .noAccount:
            self = .noAccount
        case .temporarilyUnavailable:
            self = .noPassword
        case .couldNotDetermine:
            fallthrough
        @unknown default:
            self = .couldNotDetermine
        }
    }

    public var rawValue: CKAccountStatus {
        switch self {
        case .couldNotDetermine:
            return .couldNotDetermine
        case .restricted:
            return .restricted
        case .noAccount:
            return .noAccount
        case .noPassword:
            if #available(iOS 15.0, *) {
                return .temporarilyUnavailable
            } else {
                return .noAccount
            }
        }
    }
}

public class CloudKitSyncError: TypedNSError<CloudKitSyncErrorKind> {
    public override class var errorDomain: String { "com.saturdayapps.waterme.CloudKitSyncError" }
}

// See CKError.h for all errors
public enum CloudKitSyncErrorKind: ErrorInitable {
    case password
    case network
    case rateLimit
    case storageLimit
    case partialSync
    case unknownUnknown // shows localized error message to the user AND logs to server
    case knownUnknown   // shows localized error message to the user
    // swiftlint:disable function_body_length
    // swiftlint:disable cyclomatic_complexity
    public init(_ _error: Error) {
        let error = _error as NSError
        guard error.domain == CKErrorDomain else {
            switch (error.domain, error.code) {
            case (NSURLErrorDomain, -1009), // NSURLErrorNotConnectedToInternet
                 (NSURLErrorDomain, -1200): // NSURLErrorSecureConnectionFailed
                self = .network
            case ("CKInternalErrorDomain", 1002): // Probably the same CKErrorDomain: 2
                self = .partialSync
            case (NSCocoaErrorDomain, 134419),
                 (NSCocoaErrorDomain, 4097),
                 (NSCocoaErrorDomain, 4096):
                self = .knownUnknown
            default:
                guard let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? Error else {
                    self = .unknownUnknown
                    return
                }
                self = CloudKitSyncErrorKind(underlyingError)
            }
            return
        }
        switch error.code {
        /*! CloudKit.framework encountered an error.  This is a non-recoverable error. */
        case 1: self = .unknownUnknown
        /*! Some items failed, but the operation succeeded overall. Check CKPartialErrorsByItemIDKey in the userInfo dictionary for more details. */
        case 2: self = .partialSync
        /*! Network not available */
        case 3: self = .network
        /*! Network error (available but CFNetwork gave us an error) */
        case 4: self = .network
        /*! Un-provisioned or unauthorized container. Try provisioning the container before retrying the operation. */
        case 5: self = .unknownUnknown
        /*! Service unavailable */
        case 6: self = .network
        /*! Client is being rate limited */
        case 7: self = .rateLimit
        /*! Missing entitlement */
        case 8: self = .unknownUnknown
        /*! Not authenticated (writing without being logged in, no user record) */
        case 9: self = .password
        /*! Access failure (save, fetch, or shareAccept) */
        case 10: self = .password
        /*! Record does not exist */
        case 11: self = .unknownUnknown
        /*! Bad client request (bad record graph, malformed predicate) */
        case 12: self = .unknownUnknown
        /*     CKErrorResultsTruncated API_DEPRECATED("Will not be returned", macos(10.10, 10.12), ios(8.0, 10.0), tvos(9.0, 10.0), watchos(3.0, 3.0)) = 13
        case 13: self = .unknown */
        /*! The record was rejected because the version on the server was different */
        case 14: self = .unknownUnknown
        /*! The server rejected this request. This is a non-recoverable error */
        case 15: self = .unknownUnknown
        /*! Asset file was not found */
        case 16: self = .unknownUnknown
        /*! Asset file content was modified while being saved */
        case 17: self = .unknownUnknown
        /*! App version is less than the minimum allowed version */
        case 18: self = .unknownUnknown
        /*! The server rejected the request because there was a conflict with a unique field. */
        case 19: self = .unknownUnknown
        /*! A CKOperation was explicitly cancelled */
        case 20: self = .unknownUnknown
        /*! The previousServerChangeToken value is too old and the client must re-sync from scratch */
        case 21: self = .unknownUnknown
        /*! One of the items in this batch operation failed in a zone with atomic updates, so the entire batch was rejected. */
        case 22: self = .unknownUnknown
        /*! The server is too busy to handle this zone operation. Try the operation again in a few seconds. */
        case 23: self = .rateLimit
        /*! Operation could not be completed on the given database. Likely caused by attempting to modify zones in the public database. */
        case 24: self = .unknownUnknown
        /*! Saving a record would exceed quota */
        case 25: self = .storageLimit
        /*! The specified zone does not exist on the server */
        case 26: self = .unknownUnknown
        /*! The request to the server was too large. Retry this request as a smaller batch. */
        case 27: self = .unknownUnknown
        /*! The user deleted this zone through the settings UI. Your client should either remove its local data or prompt the user before attempting to re-upload any data to this zone. */
        case 28: self = .unknownUnknown
        /*! A share cannot be saved because there are too many participants attached to the share */
        case 29: self = .unknownUnknown
        /*! A record/share cannot be saved, doing so would cause a hierarchy of records to exist in multiple shares */
        case 30: self = .unknownUnknown
        /*! The target of a record's parent or share reference was not found */
        case 31: self = .unknownUnknown
        /*! Request was rejected due to a managed account restriction */
        case 32: self = .unknownUnknown
        /*! Share Metadata cannot be determined, because the user is not a member of the share.  There are invited participants on the share with email addresses or phone numbers not associated with any iCloud account. The user may be able to join the share if they can associate one of those email addresses or phone numbers with their iCloud account via the system Share Accept UI. Call UIApplication's openURL on this share URL to have the user attempt to verify their information. */
        case 33: self = .unknownUnknown
        /*! The server received and processed this request, but the response was lost due to a network failure.  There is no guarantee that this request succeeded.  Your client should re-issue the request (if it is idempotent), or fetch data from the server to determine if the request succeeded. */
        case 34: self = .unknownUnknown
        /*! The file for this asset could not be accessed. It is likely your application does not have permission to open the file, or the file may be temporarily unavailable due to its data protection class. This operation can be retried after it is able to be opened in your process. */
        case 35: self = .unknownUnknown
        default: self = .unknownUnknown
        }
    }
    // swiftlint:enable function_body_length
    // swiftlint:enable cyclomatic_complexity
}

// Log reports for errors
// 2021/10/08
// ✔️ 288: CKErrorDomain:              2 // partial sync complete
// ✔️ 013: NSURLErrorDomain:       -1009 // NSURLErrorNotConnectedToInternet
// ✔️ 001: NSURLErrorDomain:       -1200 // secure connection failed
// ✔️ 074: CKInternalErrorDomain:   1002 // probably the same as CKErrorDomain: 2
// ✔️ 057: NSCocoaErrorDomain:    134419 // completely unknown
// ✔️ 016: NSCocoaErrorDomain:      4097 // XPC Connection Error ↰
// ✔️ 008: NSCocoaErrorDomain:      4096 // XPC Connection Error ↰
// ✔️ 003: NSCocoaErrorDomain:     -1003 // NSUnderlyingError   ⤴
