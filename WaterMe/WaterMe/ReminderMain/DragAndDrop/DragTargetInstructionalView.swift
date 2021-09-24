//
//  DragTargetInstructionalView.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 28/12/17.
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

class DragTargetInstructionalView: UIView {

    var isDragInProgress = false

    @IBOutlet private weak var textLabel: UILabel?
    @IBOutlet private weak var circleButton: UIButton?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.textLabel?.alpha = 0
        self.circleButton?.alpha = 0
        self.circleButton?.setTitle(nil, for: .normal)
        self.updateDynamicText()
    }

    private func updateDynamicText() {
        self.textLabel?.numberOfLines = self.traitCollection.verticalSizeClassIsRegular ? 2 : 4
        let message = ReminderMainViewController.LocalizedString.dragAndDropInstructionalText
        self.textLabel?.attributedText = NSAttributedString(string: message,
                                                            font: .dragInstructionalText(self.tintColor))
    }

    private enum AnimState {
        case notStarted, animating, finished
    }

    private var animState = AnimState.notStarted

    func performInstructionalAnimation(completion: (() -> Void)?) {
        switch self.animState {
        case .animating:
            completion?() // do nothing
        case .notStarted:
            self.animateFromBeginning(completion: completion)
        case .finished:
            self.animateToBeginning {
                self.animateFromBeginning(completion: completion)
            }
        }
    }

    private func animateToBeginning(completion: (() -> Void)?) {
        self.animState = .animating
        type(of: self).priv_animateNormal({
            self.textLabel?.alpha = 0
            self.circleButton?.alpha = 0
        }, completion: { _ in
            self.animState = .notStarted
            completion?()
        })
    }

    private func animateFromBeginning(completion: (() -> Void)?) {
        self.animState = .animating
        let typeOfSelf = type(of: self)
        typeOfSelf.priv_animateNormalDelayNormal({
            self.textLabel?.alpha = 1
        }, completion: { _ in
            typeOfSelf.priv_animateLongDelayLong({
                self.textLabel?.alpha = 0
            }, completion: { _ in
                typeOfSelf.priv_animateNormal({
                    self.circleButton?.alpha = 1
                }, completion: { _ in
                    self.animState = .finished
                    completion?()
                })
            })
        })
    }

    private func updateCircleImageIfNeeded() {
        let currentImage = self.circleButton?.image(for: .normal)
        let bounds = self.circleButton?.bounds ?? .zero
        guard currentImage?.size != bounds.size else { return }

        let circleStroke: CGFloat = 2
        let plusStroke: CGFloat = 3
        let plusRadius: CGFloat = 14
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let image = renderer.image { _ in
            UIColor.black.setStroke()
            let circleDiam = (bounds.height - (circleStroke * 2)) * (9 / 10)
            let circleRect = CGRect(x: (bounds.width / 2) - (circleDiam / 2),
                                    y: (bounds.height / 2) - (circleDiam / 2),
                                    width: circleDiam,
                                    height: circleDiam)
            let circlePath = UIBezierPath(ovalIn: circleRect)
            let plusVerticalPath = UIBezierPath()
            plusVerticalPath.move(to: CGPoint(x: bounds.size.width / 2,
                                              y: (bounds.size.height / 2) - plusRadius))
            plusVerticalPath.addLine(to: CGPoint(x: bounds.size.width / 2,
                                                 y: (bounds.size.height / 2) + plusRadius))
            let plusHorizontalPath = UIBezierPath()
            plusHorizontalPath.move(to: CGPoint(x: (bounds.size.width / 2) - plusRadius,
                                              y: bounds.size.height / 2))
            plusHorizontalPath.addLine(to: CGPoint(x: (bounds.size.width / 2) + plusRadius,
                                                 y: bounds.size.height / 2))
            circlePath.lineWidth = circleStroke
            circlePath.stroke(with: CGBlendMode.normal, alpha: 1.0)
            plusVerticalPath.lineWidth = plusStroke
            plusVerticalPath.stroke()
            plusHorizontalPath.lineWidth = plusStroke
            plusHorizontalPath.stroke()
        }
        self.circleButton?.setImage(image, for: .normal)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard self.isDragInProgress == false else { return }
        self.updateCircleImageIfNeeded()
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        self.updateDynamicText()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        self.updateDynamicText()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateDynamicText()
    }
}

private extension DragTargetInstructionalView {
    private class func priv_animateNormal(_ animations: @escaping () -> Void, completion: @escaping ((Bool) -> Void)) {
        UIView.animate(withDuration: self.style_animationDurationNormal,
                       delay: 0,
                       options: [],
                       animations: animations,
                       completion: completion)
    }
    private class func priv_animateNormalDelayNormal(_ animations: @escaping () -> Void, completion: @escaping ((Bool) -> Void)) {
        UIView.animate(withDuration: self.style_animationDurationNormal,
                     delay: self.style_animationDelayNormal,
                     options: [],
                     animations: animations,
                     completion: completion)
    }
    private class func priv_animateLongDelayLong(_ animations: @escaping () -> Void, completion: @escaping ((Bool) -> Void)) {
        UIView.animate(withDuration: self.style_animationDurationLong,
                       delay: self.style_animationDelayLong,
                       options: [],
                       animations: animations,
                       completion: completion)
    }
}
