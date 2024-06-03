//
//  Logger+Exceptions.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 2024/06/03.
//  Copyright © 2024 Saturday Apps.
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
#if canImport(CoreSpotlight)
import CoreSpotlight
#endif
import XCGLogger
import ServerlessLogger

internal class ExceptionDestination<T: ServerlessLoggerEventProtocol>: Logger.Destination<T> {

    override func process(logDetails: LogDetails) {

        // If the error is of a certain kind, drop it on the floor
        if let error = logDetails.userInfo[Event.kErrorKey] as? NSError {
            switch (error.domain, error.code) {
            #if canImport(CoreSpotlight)
            case (CSIndexErrorDomain, -1000), // The indexer was unavailable
                 (CSIndexErrorDomain, -1003): // Couldn’t communicate with a helper application.
                return
            #endif
            // Couldn't initialize without iCloud Account
            case (NSCocoaErrorDomain, 134400):
                return
            // remote notifications are not supported in the simulator
            case (NSCocoaErrorDomain, 3010):
                return
            default:
                break
            }
        }

        // otherwise call super
        super.process(logDetails: logDetails)
    }

}
