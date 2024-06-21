// swift-tools-version: 5.9.0

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

import PackageDescription

let PKGNAME = "V3Logger"

let package = Package(
    name: PKGNAME,
    platforms: [.iOS(.v16), .macOS(.v13), .watchOS(.v9)],
    products: [
        .library(
            name: PKGNAME,
            targets: [PKGNAME]
        ),
    ],
    dependencies: [
        .package(path: "../V3Protect"),
        .package(url: "https://github.com/jeffreybergier/JSBServerlessLogger.git", branch: "concurrency"),
    ],
    targets: [
        .target(
            name: PKGNAME,
            dependencies: [
                .byNameItem(name: "V3Protect", condition: nil),
                .product(name: "ServerlessLogger", package: "JSBServerlessLogger"),
            ],
            swiftSettings: [
              .enableExperimentalFeature("StrictConcurrency"),
              .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
    ],
    swiftLanguageVersions: [.version("5")]
)
