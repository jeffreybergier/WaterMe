//
//  String+WaterMe.swift
//  Datum
//
//  Created by Jeffrey Bergier on 5/15/17.
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

extension String {
    public var nonEmptyString: String? {
        let stripped = self.trimmingCharacters(in: .whitespacesAndNewlines)
        guard stripped.isEmpty == false else { return nil }
        return stripped
    }

    public func truncated(to length: Int) -> String? {
        guard self.count > length else { return self }
        let endIndex = self.index(self.startIndex, offsetBy: length)
        let substring = String(self[..<endIndex])
        if let trimmed = substring.nonEmptyString {
            return trimmed + "…"
        } else {
            return nil
        }
    }
}
