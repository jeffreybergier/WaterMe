// swift-tools-version:6.0.0

//
//  Created by Jeffrey Bergier on 2022/11/03.
//  Copyright © 2021 Saturday Apps.
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

let PKGNAME = "V3Interface"

let package = Package(
    name: PKGNAME,
    platforms: [.iOS(.v17), .macOS(.v13), .watchOS(.v10)],
    products: [
        .library(
           	name: PKGNAME,
            targets: [PKGNAME]
         ),
    ],
    dependencies: [
        .package(path: "../V3Datum"),
        .package(path: "../V3Nav"),
        .package(path: "../V3Style"),
        .package(path: "../V3Model"),
        .package(path: "../V3Localize"),
        .package(path: "../V3Settings"),
        .package(path: "../V3Logger"),
        .package(url: "https://github.com/jeffreybergier/Umbrella.git", branch: "waterme3-wOS10"),
    ],
    targets: [
        .target(
            name: PKGNAME,
            dependencies: [
                .byNameItem(name: "V3Datum", condition: nil),
                .byNameItem(name: "V3Nav", condition: nil),
                .byNameItem(name: "V3Style", condition: nil),
                .byNameItem(name: "V3Model", condition: nil),
                .byNameItem(name: "V3Localize", condition: nil),
                .byNameItem(name: "V3Settings", condition: nil),
                .byNameItem(name: "V3Logger", condition: nil),
                .byNameItem(name: "Umbrella", condition: nil),
            ],
            resources: [
                .process("Resources")
            ]
        ),
    ],
    swiftLanguageVersions: [.version("6")]
)
