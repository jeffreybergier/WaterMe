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

/// Dummy singleton that doesn't do much except hold the default logger
public enum Loggable {
    
    public internal(set) static var `default`: XCGLogger?

    public static func configure(with delegate: ServerlessLoggerErrorDelegate?) {
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
        self.default = log
    }
}

/// Extend any type with this protocol to get logging behavior for free.
/// If you can't extend your object because its already a protocol,
/// use `LoggableProtocolImp` to get the behavior manually.
public protocol LoggableProtocol { }

extension LoggableProtocol {
    /// Log this object
    public func log(in log: XCGLogger? = Loggable.default,
                    as level: XCGLogger.Level = .error,
                    functionName: StaticString = #function,
                    fileName: StaticString = #file,
                    lineNumber: Int = #line,
                    userInfo: [String: Any] = [:])
    {
        LoggableProtocolImp(on: self,
                            in: log,
                            as: level,
                            functionName: functionName,
                            fileName: fileName,
                            lineNumber: lineNumber,
                            userInfo: userInfo)
    }
}

/// Implementation of how the logging function should work
// swiftlint:disable:next function_parameter_count
internal func LoggableProtocolImp(on object: Any,
                                  in log: XCGLogger? = Loggable.default,
                                  as level: XCGLogger.Level,
                                  functionName: StaticString,
                                  fileName: StaticString,
                                  lineNumber: Int,
                                  userInfo: [String: Any])
{
    guard let log = log else {
        NSLog("Attempted to log but LogConfigure not performed yet.")
        return
    }

    if let error = object as? UserFacingError, error.isCritical == false {
        log.info(object, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo)
        return
    }

    log.logln(object, level: level, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo)
}
