//
//  NSUserActivity+WaterMe.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/23/18.
//  Copyright © 2018 Saturday Apps.
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

import DatumL
import Intents
import CoreSpotlight
import MobileCoreServices

typealias NSUserActivityContinuedHandler = ([UIUserActivityRestoring]?) -> Void

typealias UserActivityResult = Result<UserActivityToContinue, UserActivityToFail>

struct UserActivityToContinue {
    var activity: RestoredUserActivity
    var completion: NSUserActivityContinuedHandler
}

struct UserActivityToFail: Error {
    var error: UserActivityError
    var completion: NSUserActivityContinuedHandler?
}

extension NSUserActivity {

    fileprivate static let stringSeparator = "::"

    public static func uniqueString(for rawActivity: RawUserActivity,
                                    and uuids: [Identifier]) -> String
    {
        let uuids = uuids.sorted(by: { $0.uuid <= $1.uuid })
        return uuids.reduce(rawActivity.rawValue) { prevValue, item -> String in
            return prevValue + stringSeparator + item.uuid
        }
    }

    public static func deuniqueString(fromRawString rawString: String) -> (String, [String])? {
        let components = rawString.components(separatedBy: self.stringSeparator)
        let _first = components.first
        let rest = components.dropFirst()
        guard let first = _first else { return nil }
        return (first, Array(rest))
    }

    public var restoredUserActivityResult: Result<RestoredUserActivity, UserActivityError> {
        guard
            let rawString = self.userInfo?[CSSearchableItemActivityIdentifier] as? String,
            let (rawValue, uuids) = type(of: self).deuniqueString(fromRawString: rawString),
            let uuid = uuids.first,
            let kind = RawUserActivity(rawValue: rawValue)
        else {
            return .failure(.perform)
        }
        switch kind {
        case .editReminder:
            return .success(.editReminder(.init(rawValue: uuid)))
        case .editReminderVessel:
            return .success(.editReminderVessel(.init(rawValue: uuid)))
        case .viewReminder:
            return .success(.viewReminder(.init(rawValue: uuid)))
        case .performReminder:
            return .success(.performReminder(.init(rawValue: uuid)))
        case .indexedItem:
            assertionFailure("Unimplmented")
            return .failure(.perform)
        }
    }

    public var waterme_isEligibleForNeededServices: Bool {
        get {
            if #available(iOS 12.0, *) {
                return self.isEligibleForSearch
                    && self.isEligibleForHandoff
                    && self.isEligibleForPrediction
            } else {
                return self.isEligibleForSearch
                    && self.isEligibleForHandoff
            }
        }
        set {
            self.isEligibleForSearch = newValue
            self.isEligibleForHandoff = newValue
            if #available(iOS 12.0, *) {
                self.isEligibleForPrediction = newValue
            }
        }
    }

    public convenience init(kind: RawUserActivity, delegate: NSUserActivityDelegate) {
        self.init(activityType: kind.rawValue)
        self.delegate = delegate
        self.waterme_isEligibleForNeededServices = true
    }

    public func update(uuid: Identifier,
                       title: String,
                       phrase: String,
                       description: String,
                       thumbnailData: Data?)
    {
        guard let kind = RawUserActivity(rawValue: self.activityType) else {
            assertionFailure()
            return
        }
        let persistentIdentifier = type(of: self).uniqueString(for: kind, and: [uuid])
        self.title = title
        if #available(iOS 12.0, *) {
            self.suggestedInvocationPhrase = phrase
            self.persistentIdentifier = persistentIdentifier
        }
        self.addUserInfoEntries(from: [CSSearchableItemActivityIdentifier: persistentIdentifier])
        self.requiredUserInfoKeys = [CSSearchableItemActivityIdentifier]
        let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeContent as String)
        attributes.relatedUniqueIdentifier = persistentIdentifier
        attributes.contentDescription = description
        attributes.thumbnailData = thumbnailData
        self.contentAttributeSet = attributes
    }
}
