//
//  NSAttributedString+Font.swift
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

import Foundation

extension NSString {
    func ranges(of substring: String) -> [NSRange] {
        // make sure we have an immutable copy of the string
        // swiftlint:disable:next force_cast
        let copy = self.copy() as! NSString

        // make a sequence, return NIL to complete the sequence
        return sequence(state: 0) { state -> NSRange? in
            // get the range using the state variable to know the beginning of where to search
            let range = copy.range(of: substring, range: NSRange(location: state, length: copy.length - state))
            // populate the state variable with the location of the last find for the next iteration
            state = NSMaxRange(range)
            // if we ever find NSNotFound for the location, its time to return NIL and end the collection
            return range.location != NSNotFound ? range : nil
            }.map({ $0 })
    }
}

extension NSAttributedString {

    convenience init(string: String, font: Font) {
        self.init(string: string, attributes: font.attributes)
    }

    func appending(_ rhs: NSAttributedString) -> NSAttributedString {
        let lhs = NSMutableAttributedString(attributedString: self)
        lhs.append(rhs)
        let appended = NSAttributedString(attributedString: lhs)
        return appended
    }

    static func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
        return lhs.appending(rhs)
    }
}
