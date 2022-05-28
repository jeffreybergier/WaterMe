//
//  ReminderDragPreviewView.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 25/12/17.
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

class ReminderDragPreviewView: UIView {

    private class func newView(for reminder: Reminder) -> ReminderDragPreviewView {
        // swiftlint:disable:next force_cast
        let v = self.nib.instantiate(withOwner: nil, options: nil).first as! ReminderDragPreviewView
        v.configure(with: reminder)
        return v
    }

    class func dragPreview(for reminder: Reminder) -> UIDragPreview {
        let v = self.newView(for: reminder)
        let p = UIDragPreview(view: v)
        p.parameters.visiblePath = UIBezierPath(roundedRect: v.bounds,
                                                cornerRadius: UIApplication.style_cornerRadius)
        return p
    }

    class var nib: UINib { return UINib(nibName: "ReminderDragPreviewView", bundle: Bundle(for: self.self)) }

    @IBOutlet private weak var labelOne: UILabel?
    @IBOutlet private weak var labelTwo: UILabel?
    @IBOutlet private weak var largeEmojiImageView: EmojiImageView?
    @IBOutlet private weak var smallEmojiImageView: EmojiImageView?

    override func awakeFromNib() {
        super.awakeFromNib()

        // I think this view belongs to a different window,
        // so the trait collection is not set by the main app window
        self.style_configure()

        self.largeEmojiImageView?.size = .small
        self.largeEmojiImageView?.ring = true
        self.largeEmojiImageView?.ignoreAccessibilitySizes = true
        self.smallEmojiImageView?.size = .superSmall
        self.smallEmojiImageView?.ring = true
        self.smallEmojiImageView?.ignoreAccessibilitySizes = true
        self.reset()
    }

    func configure(with reminder: Reminder?) {
        guard let reminder = reminder else { self.reset(); return; }

        // vessel name style
        let vesselName = reminder.vessel?.displayName
        let vesselNameStyle = vesselName != nil ?
            Font.reminderVesselDragPreviewViewPrimary :
            Font.reminderVesselDragPreviewViewPrimaryDisabled
        self.labelOne?.attributedText = NSAttributedString(string: vesselName ?? LocalizedString.ReminderVessel.untitledPlant,
                                                           font: vesselNameStyle)

        // other stuff
        self.labelTwo?.attributedText = NSAttributedString(string: reminder.kind.localizedLongString,
                                                           font: .reminderVesselDragPreviewViewSecondary)
        self.largeEmojiImageView?.setIcon(reminder.vessel?.icon)
        self.smallEmojiImageView?.setKind(reminder.kind)
    }

    private func reset() {
        self.labelOne?.text = nil
        self.labelTwo?.text = nil
        self.largeEmojiImageView?.setKind(nil)
        self.smallEmojiImageView?.setKind(nil)
    }

}
