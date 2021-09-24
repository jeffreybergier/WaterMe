//
//  NSErrors.swift
//  WaterMeData
//
//  Created by Jeffrey Bergier on 11/04/2018.
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

import Foundation

extension NSError {

    private static let kDomain = "WaterMe"

    public convenience init(reminderVesselPropertyChangeUnknownCaseError: Bool?) {
        let code = 1001
        let message = "Unhandled case for ReminderVessel property changes."
        let userInfo: [String : Any] = [
            NSLocalizedFailureReasonErrorKey : message
        ]
        self.init(domain: NSError.kDomain, code: code, userInfo: userInfo)
    }

    public convenience init(reminderChangeFiredAfterListOrParentVesselWereSetToNil: Bool?) {
        let code = 1002
        let message = "Reminder change fired after list or parent vessel were set to NIL"
        let userInfo: [String : Any] = [
            NSLocalizedFailureReasonErrorKey : message
        ]
        self.init(domain: NSError.kDomain, code: code, userInfo: userInfo)
    }

    public convenience init(collectionViewBatchUpdateException exception: NSException) {
        let code = 1003
        let message = exception.reason ?? "CollectionView Threw Exception During Batch Update"
        var userInfo: [String : Any] = [
            NSLocalizedFailureErrorKey : exception.name,
            NSLocalizedFailureReasonErrorKey : message
        ]
        for (_key, value) in exception.userInfo ?? [:] {
            let key = _key as? String ?? _key.description
            userInfo[key] = value
        }
        self.init(domain: NSError.kDomain, code: code, userInfo: userInfo)
    }

    public convenience init(errorFromSanityCheckFailureReason reason: ItemAndSectionSanityCheckFailureReason) {
        switch reason {
        case .modifiedSectionMismatch(let section, let cvCount, let dataCount, let insCount, let delsCount):
            self.init(collectionViewSanityCheckFailedForModifiedSection: section, cvCount: cvCount, dataCount: dataCount, ins: insCount, dels: delsCount)
        case .unmodifiedSectionMismatch(let section, let cvCount, let dataCount):
            self.init(collectionViewSanityCheckFailedForUnmodifiedSection: section, cvCount: cvCount, dataCount: dataCount)
        case .sectionCountMismatch(let cvSectionCount, let dataSectionCount):
            self.init(collectionViewSanityCheckFailedForMismatchedSectionCount: cvSectionCount, dataSectionCount: dataSectionCount)
        }
    }

    private convenience init(collectionViewSanityCheckFailedForModifiedSection section: Int, cvCount: Int, dataCount: Int, ins: Int, dels: Int) {
        let code = 1004
        let message = "CollectionView SanityCheck failed for Modifications in Section: \(section), cvCount: \(cvCount), dataCount: \(dataCount), insertions: \(ins), deletions: \(dels)"
        let userInfo: [String : Any] = [
            NSLocalizedFailureReasonErrorKey : message
        ]
        self.init(domain: NSError.kDomain, code: code, userInfo: userInfo)
    }

    private convenience init(collectionViewSanityCheckFailedForUnmodifiedSection section: Int, cvCount: Int, dataCount: Int) {
        let code = 1005
        let message = "CollectionView SanityCheck failed for Unmodified Section: \(section), cvCount: \(cvCount), dataCount: \(dataCount)"
        let userInfo: [String : Any] = [
            NSLocalizedFailureReasonErrorKey : message
        ]
        self.init(domain: NSError.kDomain, code: code, userInfo: userInfo)
    }

    private convenience init(collectionViewSanityCheckFailedForMismatchedSectionCount cvSectionCount: Int, dataSectionCount: Int) {
        let code = 1006
        let message = "SanityCheck failed for Mismatched CollectionView Section Count: \(cvSectionCount), Data Section Count: \(dataSectionCount)"
        let userInfo: [String : Any] = [
            NSLocalizedFailureReasonErrorKey : message
        ]
        self.init(domain: NSError.kDomain, code: code, userInfo: userInfo)
    }

    internal convenience init(dataForSectionWasNilInNumberOfItemsInSection section: Int) {
        let code = 1007
        let message = "No Data was Present when getting numberOfItemsInSection for Section: \(section)"
        let userInfo: [String : Any] = [
            NSLocalizedFailureReasonErrorKey : message
        ]
        self.init(domain: NSError.kDomain, code: code, userInfo: userInfo)
    }

    internal convenience init(dataForSectionWasNilInReminderAtIndexPath indexPath: IndexPath) {
        let code = 1008
        let message = "No Data was Present when getting reminderAtIndexPath for IndexPath: \(String(describing: indexPath))"
        let userInfo: [String : Any] = [
            NSLocalizedFailureReasonErrorKey : message
        ]
        self.init(domain: NSError.kDomain, code: code, userInfo: userInfo)
    }

    public convenience init(unableToLoadEmojiFont _: Bool?) {
        let code = 1009
        let message = "Unable to load EmojiFont"
        let userInfo: [String : Any] = [
            NSLocalizedFailureReasonErrorKey : message
        ]
        self.init(domain: NSError.kDomain, code: code, userInfo: userInfo)
    }

    internal convenience init(numberOfSectionsMistmatch _: Bool?) {
        let code = 1010
        let message = "Total number of Sections did not match number of sections of loaded data."
        let userInfo: [String : Any] = [
            NSLocalizedFailureReasonErrorKey : message
        ]
        self.init(domain: NSError.kDomain, code: code, userInfo: userInfo)
    }

    public convenience init(underlyingObjectInvalidated _: Bool?) {
        let code = 1011
        let message = "The underlying REALM object was invalidated and was tried to be used again. This should not happen."
        let userInfo: [String : Any] = [
            NSLocalizedFailureReasonErrorKey : message
        ]
        self.init(domain: NSError.kDomain, code: code, userInfo: userInfo)
    }

    internal convenience init(outOfBoundsRowAtIndexPath indexPath: IndexPath) {
        let code = 1012
        let message = "Data requested out of bounds for IndexPath: \(String(describing: indexPath))"
        let userInfo: [String : Any] = [
            NSLocalizedFailureReasonErrorKey : message
        ]
        self.init(domain: NSError.kDomain, code: code, userInfo: userInfo)
    }

    public convenience init(basicControllerNotFound _: Bool) {
        let code = 1013
        let message = "Basic Controller property was set to NIL"
        let userInfo: [String : Any] = [
            NSLocalizedFailureReasonErrorKey : message
        ]
        self.init(domain: NSError.kDomain, code: code, userInfo: userInfo)
    }
}
