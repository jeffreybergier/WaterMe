//
//  NSBundle+WaterMe.swift
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
import Calculate

extension Bundle {

    internal var isReleaseBuild: Bool {
        #if RELEASE
        return true
        #else
        return false
        #endif
    }

    internal var isTestFlightInstall: Bool {
        #if DEBUG
        return false
        #else
        guard let receiptURL = self.appStoreReceiptURL else { return false }
        if receiptURL.lastPathComponent == "sandboxReceipt" {
            return true
        } else {
            return false
        }
        #endif
    }

    internal var buildNumber: Int {
        let __build = self.infoDictionary?[kCFBundleVersionKey as String] as? String
        guard let _build = __build else {
            let message = "Could not retrieve build number from bundle"
            message.log()
            assertionFailure(message)
            return -2
        }
        guard let build = Int(_build) else {
            let message = "Could not convert build number into Int"
            message.log()
            assertionFailure(message)
            return -1
        }
        return build
    }
}
