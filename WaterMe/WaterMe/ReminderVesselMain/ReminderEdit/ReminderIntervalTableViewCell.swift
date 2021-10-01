//
//  ReminderIntervalTableViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/24/17.
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

import UIKit

class ReminderIntervalTableViewCell: SimpleLabelTableViewCell {

    override class var reuseID: String { return "ReminderIntervalTableViewCell" }

    fileprivate let formatter = DateComponentsFormatter.newReminderIntervalFormatter

    override func setup() {
        super.setup()
        self.accessoryType = .disclosureIndicator
        self.prepareForReuse()
    }

    func configure(with interval: Int) {
        let intervalString = self.formatter.string(forDayInterval: interval)
        self.label.attributedText = NSAttributedString(string: intervalString,
                                                       font: .selectableTableViewCell)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.label.attributedText = nil
    }

}
