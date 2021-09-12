//
//  UIView+WaterMe.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/20/18.
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

extension UIView {
    func maxCornerRadius(withDesiredRadius desiredRadius: CGFloat) -> CGFloat {
        let width = self.frame.width
        let height = self.frame.height
        let restrictingDimension = width < height ? width : height
        let halfRestrictingDimension = restrictingDimension / 2
        if halfRestrictingDimension > desiredRadius {
            return desiredRadius
        } else {
            return halfRestrictingDimension
        }
    }
}

typealias PopoverSender = Either<(UIView, PopoverLocation), UIBarButtonItem>

enum PopoverLocation {
    case center, topCenter, topTrailing
}

extension CGRect {
    /// Used to point Popovers at the middle of the presenting view
    private var centerRect: CGRect {
        CGRect(origin: CGPoint(x: self.width / 2, y: self.height / 2), size: .zero)
    }
    private var topTrailing: CGRect {
        let width = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
                                                                       ? 0
                                                                       : self.width
        return CGRect(origin: CGPoint(x: width, y: 0), size: .zero)
    }
    private var topCenter: CGRect {
        CGRect(origin: CGPoint(x: self.width / 2, y: 0), size: .zero)
    }
    func rect(with location: PopoverLocation) -> CGRect {
        switch location {
        case .center:
            return self.centerRect
        case .topCenter:
            return self.topCenter
        case .topTrailing:
            return self.topTrailing
        }
    }
}

extension UIColor {
    var isGray: Bool {
        var _red: CGFloat = -1
        var _green: CGFloat = -2
        var _blue: CGFloat = -3
        self.getRed(&_red, green: &_green, blue: &_blue, alpha: nil)
        // adjust so we only care about 4 significant digits
        let mult: CGFloat = 10000
        let red = Int(_red * mult)
        let green = Int(_green * mult)
        let blue = Int(_blue * mult)
        // check if all three are the same
        // if they are, then its gray
        if red == blue && red == green {
            return true
        }
        return false
    }
}

extension UITraitCollection {
    @objc var userInterfaceStyleIsNormal: Bool {
        guard #available(iOS 12.0, *) else { return true }
        switch self.userInterfaceStyle {
        case .dark:
            return false
        case .light, .unspecified:
            fallthrough
        @unknown default:
            return true
        }
    }

    /**
     Checking trait collection is now so horrible in Swift
     These are simple helper properties to check for the usual cases.

     Returns: `YES` when using iPhone or iPad Skinny Split Screen.

     Returns: `NO` when using iPad.
     */
    var horizontalSizeClassIsCompact: Bool {
        switch self.horizontalSizeClass {
        case .regular:
            return false
        case .compact, .unspecified:
            fallthrough
        @unknown default:
            return true
        }
    }

    /**
     Checking trait collection is now so horrible in Swift
     These are simple helper properties to check for the usual cases.

     Returns: `YES` when iPhone is Portrait or iPad

     Returns: `NO` when iPhone is Landscape
     */
    var verticalSizeClassIsRegular: Bool {
        switch self.verticalSizeClass {
        case .compact:
            return false
        case .regular, .unspecified:
            fallthrough
        @unknown default:
            return true
        }
    }
}

extension UITraitEnvironmentLayoutDirection {
    var isLeftToRight: Bool {
        switch self {
        case .rightToLeft:
            return false
        case .leftToRight, .unspecified:
            fallthrough
        @unknown default:
            return true
        }
    }
}
