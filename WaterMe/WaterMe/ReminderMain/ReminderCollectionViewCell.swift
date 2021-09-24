//
//  ReminderCollectionViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 08/10/17.
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

class ReminderCollectionViewCell: UICollectionViewCell {
    
    static let reuseID = "ReminderCollectionViewCell"
    class var nib: UINib { return UINib(nibName: self.reuseID, bundle: Bundle(for: self.self)) }
    
    @IBOutlet private weak var labelOne: UILabel?
    @IBOutlet private weak var labelTwo: UILabel?
    @IBOutlet private weak var largeEmojiImageView: EmojiImageView?
    @IBOutlet private weak var smallEmojiImageView: EmojiImageView?
    @IBOutlet private weak var emojiImageWidthConstraint: NSLayoutConstraint?
    @IBOutlet private weak var justPerformedView: UIView?

    private var lastPerformedDate: Date?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.largeEmojiImageView?.size = .large
        self.largeEmojiImageView?.ring = true
        self.smallEmojiImageView?.size = .small
        self.smallEmojiImageView?.ring = false
        self.emojiImageWidthConstraint?.constant = type(of: self).style_emojiImageViewWidth
        self.selectedBackgroundView?.style_setCornerRadius()
        self.justPerformedView?.style_setCornerRadius()
        
        self.reset()
    }
    
    func configure(with reminder: Reminder?) {
        guard let reminder = reminder else { self.reset(); return; }

        // configure date
        self.lastPerformedDate = reminder.lastPerformDate
        
        // vessel name style
        let vesselName = reminder.vessel?.displayName
        let vesselNameStyle = vesselName != nil ?
            Font.reminderVesselCollectionViewCellPrimary(nil) :
            Font.reminderVesselCollectionViewCellPrimaryDisabled
        self.labelOne?.attributedText = NSAttributedString(string: vesselName ?? LocalizedString.ReminderVessel.untitledPlant,
                                                           font: vesselNameStyle)

        // other stuff
        self.labelTwo?.attributedText = NSAttributedString(string: reminder.kind.localizedLongString, font: .reminderVesselCollectionViewCellSecondary)
        self.largeEmojiImageView?.setIcon(reminder.vessel?.icon)
        self.smallEmojiImageView?.setKind(reminder.kind)
        self.largeEmojiImageView?.ring = true
        self.smallEmojiImageView?.ring = true
    }

    private func updateLayout() {
        switch self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
        case true:
            self.emojiImageWidthConstraint?.constant = type(of: self).style_emojiImageViewWidthAccessibility
        case false:
            self.emojiImageWidthConstraint?.constant = type(of: self).style_emojiImageViewWidth
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        self.updateLayout()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateLayout()
    }

    func willDisplay() {
        self.pulseCellIfReminderRecentlyPerformed()
    }

    private func pulseCellIfReminderRecentlyPerformed() {
        guard let lastPerformedDate = self.lastPerformedDate else { return }
        let interval = lastPerformedDate.timeIntervalSinceNow
        guard interval >= -1 && interval <= 0 else { return }
        UIView.style_animateLong({
            self.justPerformedView?.alpha = 0.5
        }, completion: { _ in
            UIView.style_animateLong {
                self.justPerformedView?.alpha = 0
            }
        })
    }
    
    private func reset() {
        self.justPerformedView?.alpha = 0
        self.lastPerformedDate = nil
        self.labelOne?.text = nil
        self.labelTwo?.text = nil
        self.largeEmojiImageView?.setKind(nil)
        self.smallEmojiImageView?.setKind(nil)
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        self.justPerformedView?.backgroundColor = self.tintColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.reset()
    }

}
