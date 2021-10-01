//
//  SimpleLabelTableViewCell.swift
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

class SimpleLabelTableViewCell: UITableViewCell {

    class var reuseID: String { return "SimpleLabelTableViewCell" }

    let label = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    func setup() {
        self.label.numberOfLines = 0
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.label)
        self.contentView.addConstraints([
            self.label.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,
                                                constant: UITableViewCell.style_labelCellLeadingPadding),
            self.contentView.trailingAnchor.constraint(equalTo: self.label.trailingAnchor,
                                                       constant: UITableViewCell.style_labelCellTrailingPadding),
            self.label.topAnchor.constraint(equalTo: self.contentView.topAnchor,
                                            constant: UITableViewCell.style_labelCellTopPadding),
            self.contentView.bottomAnchor.constraint(equalTo: self.label.bottomAnchor,
                                                     constant: UITableViewCell.style_labelCellBottomPadding)
            ])
    }
}
