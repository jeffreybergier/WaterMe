//
//  BasicWrappers.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/05/10.
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

import RealmSwift
import CoreData

internal let TESTING: Bool = NSClassFromString("XCTestCase") != nil

public struct Identifier: Hashable, Codable {
    public var uuid: String
    public init(rawValue: String) {
        self.uuid = rawValue
    }
}

public enum ItemChange<Deets> {
    case error(DatumError)
    case change(Deets)
    case deleted
}

public enum CollectionChange<Collection, Deets> {
    case initial(data: Collection)
    case update(CollectionChangeUpdate<Deets>)
    case error(error: DatumError)
}

public struct CollectionChangeUpdate<U> {
    public var insertions: [U] = []
    public var deletions: [U] = []
    public var modifications: [U] = []
    public var ez: (insertions: [U], deletions: [U], modifications: [U]) {
        return (self.insertions, self.deletions, self.modifications)
    }
}

extension CollectionChangeUpdate where U == Int {
    public func transformed(newSection section: Int) -> CollectionChangeUpdate<IndexPath> {
        return .init(insertions: self.insertions.map { IndexPath(row: $0, section: section) },
                     deletions: self.deletions.map { IndexPath(row: $0, section: section) },
                     modifications: self.modifications.map { IndexPath(row: $0, section: section) })
    }
}

extension CollectionChangeUpdate where U == IndexPath {
    public func transformed() -> CollectionChangeUpdate<Int> {
        return .init(insertions: self.insertions.map { $0.row },
                     deletions: self.deletions.map { $0.row },
                     modifications: self.modifications.map { $0.row })
    }
}

public protocol ObservationToken: AnyObject {
    func invalidate()
}

extension NotificationToken: ObservationToken {}
extension NSKeyValueObservation: ObservationToken {}

extension Array where Element == ObservationToken {
    public func invalidateTokens() {
        self.forEach { $0.invalidate() }
    }
}

internal enum Token {
    static func wrap(_ block: () -> NSObjectProtocol) -> NCTokenWrapper {
        return .init(tokens: [block()])
    }
    static func wrap(_ block: () -> ObservationToken) -> TokenWrapper {
        return .init(tokens: [block()])
    }
    static func wrap(_ block: () -> [ObservationToken]) -> TokenWrapper {
        return .init(tokens: block())
    }
}

internal class NCTokenWrapper: ObservationToken {
    private var tokens: [NSObjectProtocol]
    init(tokens: [NSObjectProtocol]) {
        self.tokens = tokens
    }
    func invalidate() {
        let nv = NotificationCenter.default
        self.tokens.forEach { nv.removeObserver($0) }
    }
}

internal class TokenWrapper: ObservationToken {
    private var tokens: [ObservationToken]
    init(tokens: [ObservationToken]) {
        self.tokens = tokens
    }
    func invalidate() {
        self.tokens.forEach { $0.invalidate() }
        self.tokens = []
    }
}

internal class UpdatingFetchedResultsControllerDelegate: NSObject, NSFetchedResultsControllerDelegate {
    private var changeInFlight: CollectionChangeUpdate<IndexPath>!
    private let block: (CollectionChangeUpdate<IndexPath>) -> Void
    internal init(_ block: @escaping (CollectionChangeUpdate<IndexPath>) -> Void) {
        self.block = block
        super.init()
    }
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.changeInFlight = .init()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at index: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath newIndex: IndexPath?)
    {
        switch type {
        case .insert:
            self.changeInFlight.insertions.append(newIndex!)
        case .move:
            self.changeInFlight.deletions.append(index!)
            self.changeInFlight.insertions.append(newIndex!)
        case .update:
            self.changeInFlight.modifications.append(newIndex!)
        case .delete:
            self.changeInFlight.deletions.append(index!)
        @unknown default:
            break
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let changeInFlight = self.changeInFlight!
        self.changeInFlight = nil
        DispatchQueue.main.async {
            self.block(changeInFlight)
        }
    }
}

extension UserDefaults {
    
    enum Constants {
        // Make sure this stays in sync with UserDefaults File
        static let kDidRunWithoutCloudSync = "DID_RUN_WITHOUT_CLOUD_SYNC"
    }
    
    var didRunWithoutCloudSync: Bool {
        get {
            guard #available(iOS 14, *) else { return true }
            guard let number = self.object(forKey: Constants.kDidRunWithoutCloudSync) as? NSNumber
                else { fatalError("Must call configure() before accessing user defaults") }
            return number.boolValue
        }
        set {
            guard #available(iOS 14, *) else { return }
            self.set(NSNumber(value: newValue), forKey: Constants.kDidRunWithoutCloudSync)
        }
    }
    
}
