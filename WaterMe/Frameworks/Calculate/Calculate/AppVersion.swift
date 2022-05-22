//
//  AppVersion.swift
//  WaterMeStore
//
//  Created by Jeffrey Bergier on 9/16/18.
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
import ServerlessLogger

public struct AppVersion: Equatable {
    public var major: Int
    public var minor: Int
    public var bug: Int
    public init?(versionString: String) {
        var rawArray = versionString.components(separatedBy: ".")
        while rawArray.count < 3 {
            rawArray.append("0")
        }
        guard rawArray.count == 3 else {
            return nil
        }
        let uintArray = rawArray.compactMap({ UInt($0) })
        let intArray = uintArray.compactMap({ Int($0) })
        guard intArray.count == 3 else { return nil }
        self.major = intArray[0]
        self.minor = intArray[1]
        self.bug = intArray[2]
    }
    public var versionString: String {
        return "\(self.major).\(self.minor).\(self.bug)"
    }
}

extension AppVersion: Comparable {
    public static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        if rhs.major > lhs.major {
            return true
        }
        let majorEqual = rhs.major == lhs.major
        if majorEqual && (rhs.minor > lhs.minor) {
            return true
        }
        let minorEqual = rhs.minor == lhs.minor
        if majorEqual && minorEqual && (rhs.bug > lhs.bug) {
            return true
        }
        return false
    }
}

extension AppVersion {
    public static func fetchFromBundle(_ bundle: Bundle = .main) -> AppVersion? {
        guard let versionString = bundle.infoDictionary?["CFBundleShortVersionString"] as? String else { return nil }
        return AppVersion(versionString: versionString)
    }
}

extension AppVersion {
    public static func fetchFromAppStore(_ completion: @escaping ((appStoreVersion: AppVersion, minimumOSVersion: AppVersion)?) -> Void) {
        guard let url = PrivateKeys.kAppInfoJSONURL else {
            completion(nil)
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    error.log(as: .info)
                    completion(nil)
                    return
                }
                let response = response as? HTTPURLResponse
                guard response?.successfulStatusCode == true else {
                    "Invalid Response: \(response?.statusCode ?? -1)".log(as: .warning)
                    completion(nil)
                    return
                }
                guard
                    let data = data,
                    let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? NSDictionary,
                    let appVersionArray = json.value(forKeyPath: "results.version") as? NSArray,
                    let osVersionArray = json.value(forKeyPath: "results.minimumOsVersion") as? NSArray,
                    let appVersionString = appVersionArray.firstObject as? String,
                    let osVersionString = osVersionArray.firstObject as? String,
                    let appVersion = AppVersion(versionString: appVersionString),
                    let osVersion = AppVersion(versionString: osVersionString)
                else {
                    "Invalid Data".log(as: .warning)
                    completion(nil)
                    return
                }
                completion((appStoreVersion: appVersion, minimumOSVersion: osVersion))
            }
        }
        task.resume()
    }
}

extension HTTPURLResponse {
    internal var successfulStatusCode: Bool {
        switch self.statusCode {
        case 200..<400:
            return true
        default:
            return false
        }
    }
}
