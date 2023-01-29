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

#if canImport(UIKit)
import UIKit
import Umbrella

extension Vessel.Icon {

    public var imageValue: JSBImage? {
        guard case .image(let data) = self else { return nil }
        return UIImage(data: data)
    }

    public init?(uncleanData: Data) {
        // all of this code assumes we're cropping to square image
        // it also assumes that we're converting it to a new image with a scale of 1
        // TODO: Add logging for NIL
        guard let rawImage = UIImage(data: uncleanData) else { return nil }
        let smallestDimension = rawImage.size.width > rawImage.size.height ? rawImage.size.height : rawImage.size.width
        let smallestScaledDimension = smallestDimension * rawImage.scale
        let originalSquareSize = CGSize(width: smallestScaledDimension, height: smallestScaledDimension)
        let cropped = rawImage.cropping(to: originalSquareSize)
        let max = UIImage.style_maxWidth
        let reducedSize = originalSquareSize.width > max ? CGSize(width: max, height: max) : originalSquareSize
        let resized = cropped.resize(toTargetSize: reducedSize)
        // TODO: Add logging for NIL
        guard let cleanData = resized.waterme_jpegData(maxBytes: UIImage.style_maxSize) else { return nil }
        self = .image(cleanData)
    }
}

#endif
