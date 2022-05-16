//
//  UIImage+WaterMe.swift
//  WaterMeData
//
//  Created by Jeffrey Bergier on 10/11/18.
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

extension UIImage {

    internal static let style_maxSize: Int = 512000
    internal static let style_maxWidth: CGFloat = 1536
    internal static let style_scale: CGFloat = 1

    internal func cropping(to size: CGSize) -> UIImage {
        var size = size
        size.width *= self.scale
        size.height *= self.scale

        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }

    internal func resize(toTargetSize targetSize: CGSize) -> UIImage {
        // inspired by Hamptin Catlin
        // https://gist.github.com/licvido/55d12a8eb76a8103c753

        let newScale = type(of: self).style_scale
        let originalSize = self.size

        let widthRatio = targetSize.width / originalSize.width
        let heightRatio = targetSize.height / originalSize.height

        // Figure out what our orientation is, and use that to form the rectangle
        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: floor(originalSize.width * heightRatio), height: floor(originalSize.height * heightRatio))
        } else {
            newSize = CGSize(width: floor(originalSize.width * widthRatio), height: floor(originalSize.height * widthRatio))
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)
        
        #if os(iOS)
        // Actually do the resizing to the rect using the ImageContext stuff
        let format = UIGraphicsImageRendererFormat()
        format.scale = newScale
        format.opaque = true
        let newImage = UIGraphicsImageRenderer(bounds: rect, format: format).image { _ in
            self.draw(in: rect)
        }
        return newImage
        #else
        // TODO: Verify this works
        UIGraphicsBeginImageContextWithOptions(rect.size, true, newScale)
        defer { UIGraphicsEndImageContext() }
        _ = UIGraphicsGetCurrentContext()!
        self.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
        #endif
    }

    internal func waterme_jpegData(maxBytes: Int? = nil,
                                   maxQuality: CGFloat = 0.8) -> Data?
    {
        var compression = maxQuality <= 1 ? maxQuality : 1
        guard let maxBytes = maxBytes else {
            return self.jpegData(compressionQuality: compression)
        }
        var compressedData: Data?
        while compressedData == nil && compression >= 0 {
            let _data = self.jpegData(compressionQuality: compression)
            compression -= 0.1
            guard let data = _data, data.count <= maxBytes else { continue }
            compressedData = data
        }
        return compressedData
    }
}
