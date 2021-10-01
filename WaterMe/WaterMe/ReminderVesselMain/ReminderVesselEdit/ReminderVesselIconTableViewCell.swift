//
//  ReminderVesselIconTableViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/2/17.
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

class ReminderVesselIconTableViewCell: UITableViewCell {

    static let reuseID = "ReminderVesselIconTableViewCell"

    @IBOutlet private weak var emojiImageView: EmojiImageView?
    @IBOutlet private weak var emojiImageViewHeightConstraint: NSLayoutConstraint?
    @IBOutlet private weak var cameraButton: UIButton?

    var iconButtonTapped: ((UIView) -> Void)?

    func configure(with icon: ReminderVesselIcon?) {
        self.cameraButton?.setTitle(nil, for: .normal)
        self.cameraButton?.setImage(#imageLiteral(resourceName: "Camera"), for: .normal)
        self.cameraButton?.accessibilityLabel = UIAlertController.LocalizedString.buttonTitleChoosePhoto
        self.emojiImageView?.setIcon(icon)
    }

    @IBAction private func iconButtonTapped(_ sender: UIView) {
        self.iconButtonTapped?(sender)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.prepareForReuse()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.cameraButton?.setAttributedTitle(nil, for: .normal)
        self.emojiImageView?.setIcon(nil)
        self.iconButtonTapped = nil
    }

    private func updateLayout() {
        self.emojiImageViewHeightConstraint?.constant =
        self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory ?
            type(of: self).style_iconButtonHeightAccessibilityTextSizeEnabled :
            type(of: self).style_iconButtonHeightAccessibilityTextSizeDisabled
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        self.updateLayout()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateLayout()
    }
}
