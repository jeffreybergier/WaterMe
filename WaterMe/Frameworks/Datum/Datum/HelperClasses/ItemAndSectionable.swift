//
//  ItemAndSectionable.swift
//  WaterMeData
//
//  Created by Jeffrey Bergier on 04/04/2018.
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
import Calculate

public protocol ItemAndSectionable {
    var numberOfSections: Int { get }
    func numberOfItems(inSection: Int) -> Int
}

public enum ItemAndSectionSanityCheckFailureReason {

    case sectionCountMismatch(oldSectionCount: Int, newSectionCount: Int)
    case modifiedSectionMismatch(section: Int, oldCount: Int, newCount: Int, insCount: Int, delsCount: Int)
    case unmodifiedSectionMismatch(section: Int, oldCount: Int, newCount: Int)

    // this is an attempt to do the sanity check the collectionview does when doing a batch update
    // before doing the batch up. So that we can bail out and just do reloadData
    // to avoid having an exception thrown
    public static func check(old: ItemAndSectionable,
                             new: ItemAndSectionable,
                             delta: (ins: [IndexPath], dels: [IndexPath]))
                             -> ItemAndSectionSanityCheckFailureReason?
    {
        if let sectionCountMismatch = self.checkSectionMismatch(old: old, new: new) {
            return sectionCountMismatch
        }
        if let rowCountMismatch = self.verifyEachSection(old: old, new: new, delta: delta) {
            return rowCountMismatch
        }
        return nil
    }

    private static func verifyEachSection(old: ItemAndSectionable,
                                          new: ItemAndSectionable,
                                          delta: (ins: [IndexPath], dels: [IndexPath])) -> ItemAndSectionSanityCheckFailureReason?
    {
        let insCounts = delta.ins.sectionCount
        let delsCounts = delta.dels.sectionCount
        for section in 0 ..< old.numberOfSections {
            let oldCount = old.numberOfItems(inSection: section)
            let newCount = new.numberOfItems(inSection: section)
            let insCount = insCounts[section, default: 0]
            let delsCount = delsCounts[section, default: 0]
            if insCount + delsCount > 0 {
                // If either insCount or delsCount are more than 0,
                // then there are insertions or deletions in the given section
                // we need to make sure the math works out
                let pass = oldCount + insCount - delsCount == newCount
                "Sanity Check: Modified Section: \(section): \(pass)".log(as: .debug)
                if pass == false {
                    return .modifiedSectionMismatch(section: section,
                                                    oldCount: oldCount,
                                                    newCount: newCount,
                                                    insCount: insCount,
                                                    delsCount: delsCount)
                }
            } else {
                // If either insCount and delsCount are both 0,
                // then there are no changes in the section at hand
                // we just need to make sure the lhs and rhs count in the section match
                let pass = oldCount == newCount
                "Sanity Check: Unmodified Section: \(section): \(pass)".log(as: .debug)
                if pass == false {
                    return .unmodifiedSectionMismatch(section: section,
                                                      oldCount: oldCount,
                                                      newCount: newCount)
                }
            }
        }
        return nil
    }

    private static func checkSectionMismatch(old: ItemAndSectionable,
                                             new: ItemAndSectionable) -> ItemAndSectionSanityCheckFailureReason?
    {
        let oldSectionCount = old.numberOfSections
        let newSectionCount = new.numberOfSections
        guard oldSectionCount != newSectionCount else { return nil }
        return .sectionCountMismatch(oldSectionCount: oldSectionCount, newSectionCount: newSectionCount)
    }
}

extension Sequence where Iterator.Element == IndexPath {
    // Counts the number of times items appear in a single section
    // Key: Section
    // Value: Number of times an items appeared from the key section
    public var sectionCount: [Int: Int] {
        return self.reduce(into: [Int: Int](), { $0[$1.section, default: 0] += 1 })
    }
}
