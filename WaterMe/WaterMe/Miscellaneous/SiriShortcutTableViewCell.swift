//
//  SiriShortcutTableViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/26/18.
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

import UIKit

class SiriShortcutTableViewCell: SimpleLabelTableViewCell {

    override class var reuseID: String { return "SiriShortcutTableViewCell" }

    private let plusButton: UIButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        self.accessoryView = self.plusButton
    }

    func configure(withLocalizedTitle localizedTitle: String) {
        self.label.attributedText = NSAttributedString(string: localizedTitle,
                                                       font: .selectableTableViewCell)
        self.plusButton.setImage(#imageLiteral(resourceName: "PlusIcon"), for: .normal)
        self.plusButton.sizeToFit()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.label.text = nil
        self.plusButton.setImage(nil, for: .normal)
    }

}
