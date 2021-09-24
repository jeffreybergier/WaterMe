//
//  EmojiPickerCollectionViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/3/17.
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

class EmojiPickerCollectionViewCell: UICollectionViewCell {

    static let reuseID = "EmojiPickerCollectionViewCell"
    class var nib: UINib { return UINib(nibName: self.reuseID, bundle: Bundle(for: self.self)) }

    @IBOutlet private weak var emojiLabel: UILabel?
    private var emojiString: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.prepareForReuse()
    }

    func configure(withEmojiString emojiString: String) {
        let accessibility = self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        self.emojiString = emojiString
        self.emojiLabel?.attributedText = NSAttributedString(string: emojiString,
                                                             font: .emojiLarge(accessibilityFontSizeEnabled: accessibility))
    }

    func updateLayout() {
        guard let emojiString = self.emojiString else { return }
        self.configure(withEmojiString: emojiString)
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
        self.emojiString = nil
        self.emojiLabel?.attributedText = nil
    }

}
