// swift-tools-version:5.5.0

//
//  Created by Jeffrey Bergier on 2022/02/05.
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

let package = Package(
    name: "Localize",
    defaultLocalization: "en",
    platforms: [.iOS(.v15), .macOS(.v12), .watchOS(.v8)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Localize",
            targets: ["Localize"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(path: "../Model"),
        .package(path: "../Style"),
        .package(url: "https://github.com/jeffreybergier/Umbrella.git", branch: "v2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Localize",
            dependencies: [
                .byNameItem(name: "Model", condition: nil),
                .byNameItem(name: "Style", condition: nil),
                .byNameItem(name: "Umbrella", condition: nil),
            ]),
        .testTarget(
            name: "LocalizeTests",
            dependencies: ["Localize"]),
    ]
)
