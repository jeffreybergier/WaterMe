//
//  Created by Jeffrey Bergier on 6/4/17.
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

public enum VesselIcon: Hashable {
    case emoji(String), image(UIImage)

    internal init?(rawImage: UIImage?, emojiString: String?) {
        if let emoji = emojiString {
            self.init(emojiString: emoji)
        } else if let image = rawImage {
            self.init(rawImage: image)
        } else {
            return nil
        }
    }

    // Hack: Needed just for the initializer above. Otherwise it produced an error.
    // self used before self.init
    private init(emojiString: String) {
        self = .emoji(emojiString)
    }

    private init(rawImage: UIImage) {
        // all of this code assumes we're cropping to square image
        // it also assumes that we're converting it to a new image with a scale of 1
        let smallestDimension = rawImage.size.width > rawImage.size.height ? rawImage.size.height : rawImage.size.width
        let smallestScaledDimension = smallestDimension * rawImage.scale
        let originalSquareSize = CGSize(width: smallestScaledDimension, height: smallestScaledDimension)
        let cropped = rawImage.cropping(to: originalSquareSize)
        let max = UIImage.style_maxWidth
        let reducedSize = originalSquareSize.width > max ? CGSize(width: max, height: max) : originalSquareSize
        let resized = cropped.resize(toTargetSize: reducedSize)
        self = .image(resized)
    }

    public var image: UIImage? {
        switch self {
        case .image(let image):
            return image
        case .emoji:
            return nil
        }
    }

    public var emoji: String? {
        switch self {
        case .image:
            return nil
        case .emoji(let string):
            return string
        }
    }
}

extension VesselIcon {

    public init?(rawImageData: Data?, emojiString: String?) {
        if let data = rawImageData, let image = UIImage(data: data) {
            self = .image(image)
        } else if let emojiString = emojiString {
            self = .emoji(emojiString)
        } else {
            return nil
        }
    }

    public var dataValue: Data? {
        switch self {
        case .emoji:
            return nil
        case .image(let image):
            let max = UIImage.style_maxSize
            guard let data = image.waterme_jpegData(maxBytes: max) else {
                let message = "Image couldn't be compressed to fit: \(max) bytes"
                message //.log()
                assertionFailure(message)
                return nil
            }
            return data
        }
    }

    internal var stringValue: String? {
        switch self {
        case .emoji(let string):
            return string
        case .image:
            return nil
        }
    }

}
