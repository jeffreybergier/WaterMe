//
//  SettingsInfoTableViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 15/1/18.
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

import DatumL
import UIKit

class SettingsInfoTableViewCell: UITableViewCell {

    class var reuseID: String { return "SettingsInfoTableViewCell" }
    class var nib: UINib { return UINib(nibName: self.reuseID, bundle: Bundle(for: self.self)) }

    @IBOutlet private weak var leadingConstraint: NSLayoutConstraint?
    @IBOutlet private weak var trailingConstraint: NSLayoutConstraint?
    @IBOutlet private weak var topConstraint: NSLayoutConstraint?
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint?

    @IBOutlet private weak var emojiImageView: EmojiImageView?
    @IBOutlet private weak var label: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.leadingConstraint?.constant = UITableViewCell.style_labelCellLeadingPadding
        self.trailingConstraint?.constant = UITableViewCell.style_labelCellTrailingPadding
        self.topConstraint?.constant = UITableViewCell.style_labelCellTopPadding
        self.bottomConstraint?.constant = UITableViewCell.style_labelCellBottomPadding
        self.emojiImageView?.size = .small
        self.emojiImageView?.ring = true
        self.prepareForReuse()
    }

    func configure(with icon: ReminderVesselIcon?, and text: String) {
        self.label?.attributedText = NSAttributedString(string: text, font: .selectableTableViewCell)
        guard let icon = icon else { return }
        self.emojiImageView?.setIcon(icon)
    }

    private func updateLayout() {
        self.emojiImageView?.isHidden = self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        self.updateLayout()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateLayout()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.label?.attributedText = nil
        self.emojiImageView?.setIcon(nil)
    }
}
