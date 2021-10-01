//
//  LastPerformedTableViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/25/17.
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

class LastPerformedTableViewCell: SimpleLabelTableViewCell {

    override class var reuseID: String { return "LastPerformedTableViewCell" }

    private let formatter = Formatter.newTimeAgoFormatter

    override func setup() {
        super.setup()
        self.selectionStyle = .none
        self.prepareForReuse()
    }

    func configureWith(lastPerformedDate: Date?) {
        let dateString = self.formatter.timeAgoString(for: lastPerformedDate)
        self.label.attributedText = NSAttributedString(string: dateString, font: .readOnlyTableViewCell)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.label.attributedText = nil
    }
}
