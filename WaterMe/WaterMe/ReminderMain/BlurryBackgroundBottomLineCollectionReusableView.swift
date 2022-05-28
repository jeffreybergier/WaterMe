//
//  BlurryBackgroundBottomLineCollectionReusableView.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 20/10/17.
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

class BlurryBackgroundBottomLineCollectionReusableView: UICollectionReusableView {

    class var reuseID: String { fatalError("Must Implement ReuseID Yourself") }
    class var kind: String { fatalError("Must Implement Kind Yourself") }

    let stackView: UIStackView = {
        let v = UIStackView()
        v.axis = .horizontal
        v.alignment = .center
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    let backgroundView = UIVisualEffectView.style_systemMaterial()
    var color: UIColor? {
        didSet {
            self.colorView.backgroundColor = self.color
        }
    }

    private let colorView: UIView = {
        let v = UIView()
        v.backgroundColor = .red
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    func commonInit() {
        // configure BGView
        _ = {
            self.addSubview(self.backgroundView)
            let top = NSLayoutConstraint(item: self.backgroundView,
                                         attribute: .top,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .top,
                                         multiplier: 1,
                                         constant: 4)
            top.priority = UILayoutPriority.defaultHigh
            let bottom = NSLayoutConstraint(item: self,
                                            attribute: .bottom,
                                            relatedBy: .equal,
                                            toItem: self.backgroundView,
                                            attribute: .bottom,
                                            multiplier: 1,
                                            constant: 4)
            bottom.priority = UILayoutPriority.defaultHigh
            self.addConstraints([
                self.backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
                self.trailingAnchor.constraint(equalTo: self.backgroundView.trailingAnchor, constant: 8),
                top,
                bottom
                ])
        }()

        // configure colorview
        _ = {
            let cv = self.backgroundView.contentView
            cv.addSubview(self.colorView)
            cv.addConstraints([
                cv.leadingAnchor.constraint(equalTo: self.colorView.leadingAnchor),
                cv.trailingAnchor.constraint(equalTo: self.colorView.trailingAnchor),
                cv.bottomAnchor.constraint(equalTo: self.colorView.bottomAnchor),
                self.colorView.heightAnchor.constraint(equalToConstant: 3)
                ])
        }()

        // configure stackView
        _ = {
            self.addSubview(self.stackView)
            self.addConstraints([
                self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
                self.trailingAnchor.constraint(equalTo: self.stackView.trailingAnchor, constant: 20),
                self.centerYAnchor.constraint(equalTo: self.stackView.centerYAnchor)
                ])
        }()
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        if self.tintColor.isGray {
            self.colorView.backgroundColor = self.tintColor
        } else {
            self.colorView.backgroundColor = self.color
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if self.bounds.height <= 2 {
            self.stackView.alpha = 0
            self.backgroundView.alpha = 0
        } else {
            self.stackView.alpha = 1
            self.backgroundView.alpha = 1
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.color = nil
    }
}
