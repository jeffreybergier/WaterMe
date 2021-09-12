//
//  SimpleImageViewerSubclass.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/14/18.
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

import SimpleImageViewer

class DismissHandlingImageViewerController: ImageViewerController {

    override func closeButtonPressed() {
        if let config = self.configuration as? DismissHandlingImageViewerConfiguration {
            config.completion(self)
        } else {
            self.dismissNoForReal()
        }
    }
}

class DismissHandlingImageViewerConfiguration: ImageViewerConfiguration {
    
    let completion: ((UIViewController) -> Void)
    
    init(image: UIImage? = nil,
         imageView: UIImageView? = nil,
         imageBlock: ImageBlock? = nil,
         completion: @escaping ((UIViewController) -> Void) = { _ in })
    {
        self.completion = completion
        super.init(image: image, imageView: imageView, imageBlock: imageBlock)
        Analytics.log(viewOperation: .viewReminderVesselPhoto)
    }
}
