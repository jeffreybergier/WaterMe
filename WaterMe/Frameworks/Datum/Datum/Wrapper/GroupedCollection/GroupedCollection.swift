//
//  ReminderGedeg.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 19/10/17.
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

import Calculate

/**
 Groups changes from a bunch of different queries so they appear like one big query
 */
internal class GroupedCollection<
    Section: Hashable & RawRepresentable,
    Query: CollectionQuery
    >
    : NSObject, BaseCollection, CollectionQuery, ObservationToken
    where Query.Index == Int,
          Section.RawValue == Int
{

    internal typealias InputChange = CollectionChange<AnyCollection<Query.Element, Query.Index>, Query.Index>
    internal typealias OutputChange = CollectionChange<AnyCollection<Query.Element, IndexPath>, IndexPath>

    // MARK: IVAR Storage

    private var data: [Section: AnyCollection<Query.Element, Query.Index>] = [:]
    private let queries: [Section: Query]
    private let updateBatcher = Batcher()

    // TODO: Consider removing the closure from here. Its not used
    private var currentObserver: (closure: ((OutputChange) -> Void)?, tokens: [ObservationToken])?

    private var allSectionsFinishedLoading: Bool {
        return self.data.count == self.queries.count
    }

    // MARK: INIT

    init(queries: [Section: Query]) {
        self.queries = queries
        super.init()
    }

    // MARK: CollectionQuery

    func observe(_ block: @escaping (OutputChange) -> Void) -> ObservationToken {
        guard self.currentObserver == nil else {
            assertionFailure("")
            return self
        }
        self.updateBatcher.batchFired = block
        var tokens = [ObservationToken]()
        for (section, query) in self.queries {
            let t = query.observe { [weak self] change in
                guard let self = self else { return }
                switch change {
                case .initial(let data):
                    self.data[section] = data
                    if self.allSectionsFinishedLoading {
                        block(.initial(data: AnyCollection(self)))
                    }
                case .update(let change):
                    self.updateBatcher.append(change: change, for: section)
                case .error:
                    self.invalidate()
                    block(.error(error: .readError))
                }
            }
            tokens.append(t)
        }
        self.currentObserver = (block, tokens)
        return self
    }

    // MARK: BaseCollection

    func count(at index: IndexPath?) -> Int? {
        // if we haven't finished loading data, always return 0
        guard self.allSectionsFinishedLoading == true else {
            return 0
        }

        // if NIL, return `numberOfSections`
        guard let index = index else {
            return self.data.count
        }

        guard
            let section = Section(rawValue: index.section),
            let collection = self.data[section]
        else {
            let error = NSError(dataForSectionWasNilInNumberOfItemsInSection: index.section)
            error.log()
            return nil
        }
        return collection.count
    }

    subscript(index: IndexPath) -> Query.Element? {
        // if we haven't finished loading data, always return 0
        guard self.allSectionsFinishedLoading == true else {
            return nil
        }

        guard
            let section = Section(rawValue: index.section),
            let collection = self.data[section]
        else {
            let error = NSError(dataForSectionWasNilInReminderAtIndexPath: index)
            assertionFailure(String(describing: error))
            error.log()
            return nil
        }

        // swiftlint:disable:next todo
        // FIXME: Crasher Workaround - http://crashes.to/s/ba8c0f6c9ad
        // Sometimes this method is called when an index out of bounds.
        // This should not happen, but this check works around it.
        let row = index.row
        guard collection.count > row else {
            let error = NSError(outOfBoundsRowAtIndexPath: index)
            assertionFailure(String(describing: error))
            error.log(as: .info)
            return nil
        }

        return collection[row]
    }

    func index(of item: Query.Element) -> IndexPath? {
        // if we haven't finished loading data, always return 0
        guard self.allSectionsFinishedLoading == true else {
            return nil
        }

        for (section, collection) in self.data {
            guard let row = collection.index(of: item) else { continue }
            return IndexPath(row: row, section: section.rawValue)
        }
        return nil
    }

    func indexOfItem(with identifier: Identifier) -> IndexPath? {
        // if we haven't finished loading data, always return 0
        guard self.allSectionsFinishedLoading == true else {
            return nil
        }

        for (section, collection) in self.data {
            guard let row = collection.indexOfItem(with: identifier) else { continue }
            return IndexPath(row: row, section: section.rawValue)
        }
        return nil
    }

    // MARK: ObservationToken

    internal func invalidate() {
        let tokens = self.currentObserver?.tokens
        self.currentObserver = nil
        tokens?.invalidateTokens()
    }

    deinit {
        self.invalidate()
    }

    // MARK: Group the Updates

    private class Batcher {
        // swiftlint:disable:next nesting
        typealias OutputUpdate = CollectionChangeUpdate<IndexPath>
        // swiftlint:disable:next nesting
        typealias InputUpdate = CollectionChangeUpdate<Query.Index>
        private var timer: Timer?
        private var updates = [OutputUpdate]()
        var batchFired: ((OutputChange) -> Void)?
        func append(change: InputUpdate, for section: Section) {
            self.timer?.invalidate()
            let transformed = change.transformed(newSection: section.rawValue)
            self.updates.append(transformed)
            self.timer = Timer.scheduledTimer(timeInterval: 0.001,
                                              target: self,
                                              selector: #selector(self.timerFired(_:)),
                                              userInfo: nil,
                                              repeats: false)
        }
        @objc private func timerFired(_ timer: Timer?) {
            timer?.invalidate()
            self.timer?.invalidate()
            self.timer = nil
            let updates = self.updates
            self.updates = []
            let ins = Set(updates.flatMap { $0.insertions })
            let dels = Set(updates.flatMap { $0.deletions })
            // for some reason core data puts an insert and a modification
            // of the same item. But when grouped, this causes the
            // collectionview to throw an exception.
            let mods = Set(
                updates.flatMap { $0.modifications }
            ).subtracting(ins)
            self.batchFired?(.update(.init(insertions: Array(ins),
                                           deletions: Array(dels),
                                           modifications: Array(mods))))
        }
    }
}
