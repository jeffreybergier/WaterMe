//
//  ReminderKindTableViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/23/17.
//  Copyright © 2017 Saturday Apps.
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
import UIKit

class ReminderKindTableViewCell: SimpleLabelTableViewCell {

    override class var reuseID: String { return "ReminderKindTableViewCell" }

    override func setup() {
        super.setup()
        self.prepareForReuse()
    }

    func configure(rowNumber: Int, compareWith compare: ReminderKind) {
        let id = ReminderKind(row: rowNumber)
        self.label.attributedText = NSAttributedString(string: id.localizedShortString, font: .selectableTableViewCell)
        self.accessoryType = id.isSameKind(as: compare) ? .checkmark : .none
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.label.attributedText = nil
    }

}

extension ReminderKind {
    var localizedLongString: String {
        switch self {
        case .water:
            return LocalizedString.waterLong
        case .fertilize:
            return LocalizedString.fertilizeLong
        case .trim:
            return LocalizedString.trimLong
        case .mist:
            return LocalizedString.mistLong
        case .move:
            return LocalizedString.moveLong
        case .other(let description):
            return description ?? LocalizedString.other
        }
    }
    var localizedShortString: String {
        switch self {
        case .water:
            return LocalizedString.waterShort
        case .fertilize:
            return LocalizedString.fertilizeShort
        case .trim:
            return LocalizedString.trimShort
        case .mist:
            return LocalizedString.mistShort
        case .move:
            return LocalizedString.moveShort
        case .other:
            return LocalizedString.other
        }
    }
    var localizedSpotlightString: String {
        switch self {
        case .water:
            return LocalizedString.waterShort
        case .fertilize:
            return LocalizedString.fertilizeShort
        case .trim:
            return LocalizedString.trimShort
        case .mist:
            return LocalizedString.mistShort
        case .move:
            return LocalizedString.moveShort
        case .other(let description):
            return description ?? LocalizedString.other
        }
    }
    // swiftlint:disable:next cyclomatic_complexity
    fileprivate func isSameKind(as other: ReminderKind) -> Bool {
        switch self {
        case .water:
            guard case .water = other else { return false }
            return true
        case .fertilize:
            guard case .fertilize = other else { return false }
            return true
        case .trim:
            guard case .trim = other else { return false }
            return true
        case .mist:
            guard case .mist = other else { return false }
            return true
        case .move:
            guard case .move = other else { return false }
            return true
        case .other:
            guard case .other = other else { return false }
            return true
        }
    }
    init(row: Int) {
        switch row {
        case 0:
            self = .water
        case 1:
            self = .fertilize
        case 2:
            self = .trim
        case 3:
            self = .mist
        case 4:
            self = .move(location: nil)
        case 5:
            self = .other(description: nil)
        default:
            fatalError("Too Many Rows in Section")
        }
    }
}
