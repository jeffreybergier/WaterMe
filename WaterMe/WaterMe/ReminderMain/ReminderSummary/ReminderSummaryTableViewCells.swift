//
//  SingleLabelTableViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/5/18.
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

class RoundedBackgroundViewTableViewCell: UITableViewCell {

    @IBOutlet private(set) weak var highlightView: UIView?
    @IBOutlet private(set) weak var cornerRadiusView: UIView?
    @IBOutlet private(set) weak var hairlineView: UIView?
    @IBOutlet var stackViews: [UIStackView]?

    var locationInGroup: VerticalLocationInGroup = .alone {
        didSet {
            switch self.locationInGroup {
            case .alone, .bottom:
                self.hairlineView?.isHidden = true
            case .top, .middle:
                self.hairlineView?.isHidden = false
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.prepareForReuse()
        self.stackViews?.forEach { stackView in
            stackView.spacing = ReminderSummaryViewController.style_primaryLabelSublabelSpacing
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let change = {
            self.highlightView?.alpha = highlighted ?
                ReminderSummaryViewController.style_tableViewHighlightAlpha : 0
        }
        guard animated else {
            change()
            return
        }
        UIView.style_animateNormal {
            change()
        }
        super.setHighlighted(highlighted, animated: animated)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        let change = {
            self.highlightView?.alpha = selected ?
                ReminderSummaryViewController.style_tableViewHighlightAlpha : 0
        }
        guard animated else {
            change()
            return
        }
        UIView.style_animateNormal {
            change()
        }
        super.setSelected(selected, animated: animated)
    }

    override func layoutSubviews() {
        if let crv = self.cornerRadiusView {
            crv.style_setCornerRadius()
            crv.clipsToBounds = true
            self.locationInGroup.configureCornerMask(on: crv.layer)
        }
        if let hlv = self.highlightView {
            hlv.style_setCornerRadius()
            hlv.clipsToBounds = true
            self.locationInGroup.configureCornerMask(on: hlv.layer)
        }
        super.layoutSubviews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.locationInGroup = .alone
        self.hairlineView?.backgroundColor = .clear
        self.highlightView?.backgroundColor = .black
        self.highlightView?.alpha = 0
    }

}

class ButtonTableViewCell: RoundedBackgroundViewTableViewCell {

    static let reuseIDActionCell = "ActionCell"
    static let reuseIDCancelCell = "CancelCell"

    @IBOutlet private(set) weak var label: UILabel?

    override func prepareForReuse() {
        super.prepareForReuse()
        self.label?.text = nil
    }
}

class InfoTableViewCell: RoundedBackgroundViewTableViewCell {

    static let reuseIDInfoCell = "InfoCell"
    static let reuseIDNoteCell = "NoteCell"

    private(set) lazy var dueDateFormatter = Formatter.newDueDateFormatter
    private(set) lazy var timeAgoDateFormatter = Formatter.newTimeAgoFormatter
    private(set) lazy var intervalFormatter = DateComponentsFormatter.newReminderIntervalFormatter

    @IBOutlet private(set) weak var stackView0: UIStackView?
    @IBOutlet private(set) weak var label0: UILabel?
    @IBOutlet private(set) weak var sublabel0: UILabel?

    @IBOutlet private(set) weak var stackView1: UIStackView?
    @IBOutlet private(set) weak var label1: UILabel?
    @IBOutlet private(set) weak var sublabel1: UILabel?

    @IBOutlet private(set) weak var stackView2: UIStackView?
    @IBOutlet private(set) weak var label2: UILabel?
    @IBOutlet private(set) weak var sublabel2: UILabel?

    override func prepareForReuse() {
        super.prepareForReuse()
        self.stackView0?.isHidden = false
        self.label0?.text = nil
        self.sublabel0?.text = nil
        self.stackView1?.isHidden = false
        self.label1?.text = nil
        self.sublabel1?.text = nil
        self.stackView2?.isHidden = false
        self.label2?.text = nil
        self.sublabel2?.text = nil
    }
}

enum VerticalLocationInGroup {

    case alone, bottom, top, middle

    func configureCornerMask(on layer: CALayer) {
        switch self {
        case .alone:
            layer.maskedCorners = [
                .layerMaxXMaxYCorner,
                .layerMaxXMinYCorner,
                .layerMinXMaxYCorner,
                .layerMinXMinYCorner
            ]
        case .bottom:
            layer.maskedCorners = [
                .layerMaxXMaxYCorner,
                .layerMinXMaxYCorner
            ]
        case .middle:
            layer.maskedCorners = []
        case .top:
            layer.maskedCorners = [
                .layerMaxXMinYCorner,
                .layerMinXMinYCorner
            ]
        }
    }
}
