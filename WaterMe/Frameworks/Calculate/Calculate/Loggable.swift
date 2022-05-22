//
//  Loggable.swift
//  Calculate
//
//  Created by Jeffrey Bergier on 2020/09/12.
//  Copyright © 2020 Saturday Apps.
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

import XCGLogger
import CryptoKit
import ServerlessLogger

public func LoggableConfigure(with delegate: ServerlessLoggerErrorDelegate?) {
    let identifier = "WaterMe-Lambda-Logger"
    var _log: XCGLogger?
    if #available(iOS 13.0, *), let loggerEndpoint = PrivateKeys.kLoggerEndpoint {
        let endpoint = URLComponents(url: loggerEndpoint, resolvingAgainstBaseURL: false)!
        let key = SymmetricKey(data: PrivateKeys.kLoggerKey)
        var config = Logger.DefaultSecureConfiguration(identifier: identifier,
                                                       endpointURL: endpoint,
                                                       hmacKey: key,
                                                       logLevel: .warning,
                                                       errorDelegate: delegate)
        config.storageLocation.appName = "WaterMe"
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
