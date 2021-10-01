//
//  UIFont+Font.swift
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
import Calculate

extension Font {
    static var bodyPlusPlusPlus: UIFont {
        return UIFont.preferredFont(forTextStyle: .title1)
    }
    static var bodyPlusPlus: UIFont {
        return UIFont.preferredFont(forTextStyle: .title2)
    }
    static var bodyPlus: UIFont {
        return UIFont.preferredFont(forTextStyle: .title3)
    }
    static var body: UIFont {
        return UIFont.preferredFont(forTextStyle: .body)
    }
    static var bodyMinus: UIFont {
        return UIFont.preferredFont(forTextStyle: .callout)
    }
    static var bodyMinusBold: UIFont {
        return UIFont.preferredFont(forTextStyle: .subheadline)
    }
    static var bodyPlusBold: UIFont {
        let body = UIFont.preferredFont(forTextStyle: .title3)
        return UIFont.boldSystemFont(ofSize: body.pointSize)
    }
    static var bodyBold: UIFont {
        let body = UIFont.preferredFont(forTextStyle: .body)
        return UIFont.boldSystemFont(ofSize: body.pointSize)
    }
    static var bodyIgnoringDynamicType: UIFont {
        return UIFont.systemFont(ofSize: 18)
    }
    static var bodyMinusIgnoringDynamicType: UIFont {
        return UIFont.systemFont(ofSize: 14)
    }
    fileprivate static var cachedEmojiFontWithSize: [CGFloat: UIFont] = [:]
    static var customEmojiLoaded: Bool = false
    static func emojiFont(ofSize size: CGFloat) -> UIFont {
        // custom emojis only work on iOS 12 and higher for some reason
        guard #available(iOS 12.0, *) else { return UIFont.systemFont(ofSize: size) }

        // look for cached font
        if let cachedFont = self.cachedEmojiFontWithSize[size] {
            return cachedFont
        }

        // try to load the custom emoji font
        guard let customFont = UIFont(name: "AppleColorEmoj2", size: size) else {
            let error = NSError(unableToLoadEmojiFont: nil)
            error.log()
            Analytics.log(error: error)
            return UIFont.systemFont(ofSize: size)
        }

        // cache it for later
        self.cachedEmojiFontWithSize[size] = customFont
        self.customEmojiLoaded = true
        return customFont
    }
}
