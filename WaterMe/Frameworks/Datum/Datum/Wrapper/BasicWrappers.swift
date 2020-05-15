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

public class DatumCollection<U, T: RealmSwift.Object, C: RandomAccessCollection> where C.Element == T, C.Index == Int {
    public var count: Int { return self.collection.count }
    internal let collection: C
    private let transform: (T) -> U
    init(_ collection: C, transform: @escaping (T) -> U) {
        self.collection = collection
        self.transform = transform
    }
    public subscript(index: Int) -> U { self.transform(self.collection[index]) }
    public func compactMap<ElementOfResult>(_ transform: (U) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        return try self.collection.compactMap { try transform(self.transform($0)) }
    }
}

public protocol ObservationToken {
    func invalidate()
}

extension NotificationToken: ObservationToken {}