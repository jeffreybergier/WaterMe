//
//  ReminderWrapper.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/05/15.
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

import Foundation

public enum ReminderConstants {
    public static let minimumInterval: Int = 1
    public static let maximumInterval: Int = 365
    public static let defaultInterval: Int = 7
}

public protocol Reminder: ModelCompleteCheckable {
    var kind: ReminderKind { get }
    var uuid: String { get }
    var interval: Int { get }
    var isEnabled: Bool { get }
    var note: String? { get }
    var nextPerformDate: Date? { get }
    var lastPerformDate: Date? { get }
    var isModelComplete: ModelCompleteError? { get }
    var vessel: ReminderVessel? { get }
    func observe(_ block: @escaping (ReminderChange) -> Void) -> ObservationToken
    func observePerforms(_ block: @escaping (ReminderPerformCollectionChange) -> Void) -> ObservationToken
}

public typealias ReminderChange = ItemChange<Void>
public typealias ReminderCollection = AnyCollection<Reminder, Int>
public typealias GroupedReminderCollection = AnyCollection<Reminder, IndexPath>
public typealias ReminderCollectionChange = CollectionChange<ReminderCollection, Int>
public typealias GroupedReminderCollectionChange = CollectionChange<GroupedReminderCollection, IndexPath>
