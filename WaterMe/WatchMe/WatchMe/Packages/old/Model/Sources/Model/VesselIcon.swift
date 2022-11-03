//
//  Created by Jeffrey Bergier on 2022/02/04.
//  Copyright © 2022 Saturday Apps.
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

public protocol VesselIconProtocol {
    var stringValue: String? { get }
    var dataValue: Data? { get }
    var imageValue: XPImage? { get }
    init?(cleanData: Data?, cleanString: String?)
    init?(uncleanData: Data)
    init?(uncleanString: String)
}

public enum VesselIcon: VesselIconProtocol {

    case emoji(String), image(Data)

    public var stringValue: String? {
        guard case .emoji(let string) = self else { return nil }
        return string
    }

    public var dataValue: Data? {
        guard case .image(let data) = self else { return nil }
        return data
    }

    public init?(cleanData: Data?, cleanString: String?) {
        if let data = cleanData {
            self = .image(data)
            return
        }
        if let string = cleanString {
            self = .emoji(string)
            return
        }
        return nil
    }

    public init?(uncleanString: String) {
        return nil
    }
}

#if canImport(UIKit)
import UIKit
public typealias XPImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias XPImage = NSImage
#endif
