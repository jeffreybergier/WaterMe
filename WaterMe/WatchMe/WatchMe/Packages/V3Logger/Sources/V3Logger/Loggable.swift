//
//  Loggable.swift
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
import CryptoKit
import XCGLogger
import ServerlessLogger
import V3Protect

// TODO: Update ServerlessLogger.Loggable to support everything needed here
public func LoggableConfigure(with delegate: ServerlessLoggerErrorDelegate?) {
    let identifier = "WatchMe-Lambda-Logger"
    var _log: XCGLogger?
    if let loggerEndpoint = V3Secrets.kLoggerEndpoint {
        let endpoint = URLComponents(url: loggerEndpoint, resolvingAgainstBaseURL: false)!
        let key = SymmetricKey(data: V3Secrets.kLoggerKey)
        var config = Logger.DefaultSecureConfiguration(identifier: identifier,
                                                       endpointURL: endpoint,
                                                       hmacKey: key,
                                                       logLevel: .warning,
                                                       errorDelegate: delegate)
        config.storageLocation.appName = "WatchMe"
        let destination = try? ExceptionDestination<Event>(configuration: config)
        _log = try? Logger(configuration: config, includeDefaultXCGDestinations: true, includeDefaultJSBDestinations: destination == nil)
        if let destination = destination {
            _log?.add(destination: destination)
        }
    }
    let log = _log ?? XCGLogger(identifier: identifier, includeDefaultDestinations: true)
    #if DEBUG
    log.setup(level: .debug, showLogIdentifier: false, showFunctionName: true, showThreadName: true, showLevel: true, showFileNames: false, showLineNumbers: false, showDate: true, writeToFile: false, fileLevel: .debug)
    #else
    log.setup(level: .warning, showLogIdentifier: false, showFunctionName: true, showThreadName: true, showLevel: true, showFileNames: false, showLineNumbers: false, showDate: true, writeToFile: false, fileLevel: .warning)
    #endif
    ServerlessLogger.log = log
}
