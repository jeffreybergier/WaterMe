//
//  EmojiImageView.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 7/31/17.
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

class EmojiImageView: UIView {

    init() {
        super.init(frame: .zero)
        self.initConfigure()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initConfigure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initConfigure()
    }

    private func initConfigure() {
        let imageView = UIImageView()
        let label = UILabel()
        let views = [imageView, label]
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        self.addSubview(stackView)
        let constraints = [
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            self.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 0),
            self.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 0)
        ]
        self.addConstraints(constraints)
        label.isHidden = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        let maskLayer = CAShapeLayer()
        imageView.layer.mask = maskLayer
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.axis = .vertical
        self.imageViewMaskLayer = maskLayer
        self.imageView = imageView
        self.label = label
        self.backgroundColor = Color.systemBackgroundColor
    }

    enum Size {
        case superSmall, small, large
        func attributedString(with string: String, ignoreAccessibilitySizes: Bool) -> NSAttributedString {
            let accessibility = ignoreAccessibilitySizes ? false : UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory
            switch self {
            case .superSmall:
                let style = Font.emojiSuperSmall
                return NSAttributedString(string: string, font: style)
            case .small:
                let style = Font.emojiSmall(accessibilityFontSizeEnabled: accessibility)
                return NSAttributedString(string: string, font: style)
            case .large:
                let style = Font.emojiLarge(accessibilityFontSizeEnabled: accessibility)
                return NSAttributedString(string: string, font: style)
            }
        }
    }

    var size: Size = .large
    var ring = true
    var ignoreAccessibilitySizes = false

    private weak var imageView: UIImageView?
    private weak var label: UILabel?
    private weak var imageViewMaskLayer: CAShapeLayer?

    func setIcon(_ icon: ReminderVesselIcon?, for controlState: UIControl.State = .normal) {

        guard let icon = icon else {
            self.alpha = 0.4
            self.label?.attributedText = self.size.attributedString(with: "🌸", ignoreAccessibilitySizes: self.ignoreAccessibilitySizes)
            self.label?.isHidden = false
            self.imageView?.image = nil
            self.imageView?.isHidden = true
            return
        }

        self.alpha = 1.0
        switch icon {
        case .emoji(let string):
            self.imageView?.image = nil
            self.imageView?.isHidden = true
            self.label?.attributedText = self.size.attributedString(with: string, ignoreAccessibilitySizes: self.ignoreAccessibilitySizes)
            self.label?.isHidden = false
        case .image(let image):
            self.imageView?.image = image
            self.imageView?.isHidden = false
            self.imageView?.contentMode = .scaleAspectFill
            self.label?.attributedText = nil
            self.label?.isHidden = true
        }
    }

    func setKind(_ kind: ReminderKind?, for controlState: UIControl.State = .normal) {

        guard let kind = kind else {
            self.alpha = 0.4
            self.label?.attributedText = self.size.attributedString(with: "🌸", ignoreAccessibilitySizes: self.ignoreAccessibilitySizes)
            self.label?.isHidden = false
            self.imageView?.image = nil
            self.imageView?.isHidden = true
            return
        }

        let image: UIImage?
        switch kind {
        case .water:
            image = #imageLiteral(resourceName: "ReminderKindWater")
        case .fertilize:
            image = #imageLiteral(resourceName: "ReminderKindFertilize")
        case .trim:
            image = #imageLiteral(resourceName: "ReminderKindTrim")
        case .mist:
            image = #imageLiteral(resourceName: "ReminderKindMist")
        case .move:
            image = #imageLiteral(resourceName: "ReminderKindMove")
        case .other:
            image = #imageLiteral(resourceName: "ReminderKindOther")
        }
        self.imageView?.image = image
        self.imageView?.contentMode = .scaleAspectFit
        self.alpha = 1.0
        self.label?.attributedText = nil
        self.label?.isHidden = true
        self.imageView?.isHidden = false
    }

    private func updateRingBounds() {
        let bounds = self.bounds
        let cornerRadius = floor(bounds.size.width / 2)
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        self.imageViewMaskLayer?.path = path.cgPath
        switch self.size {
        case .superSmall, .small:
            self.layer.borderWidth = self.ring ? 1 : 0
        case .large:
            self.layer.borderWidth = self.ring ? 2 : 0
        }
        self.layer.cornerRadius = self.ring ? cornerRadius : 0
    }

    private func updateRingColor() {
        self.layer.borderColor = self.ring ? self.tintColor.cgColor : nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateRingBounds()
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        self.updateRingColor()
    }
}
