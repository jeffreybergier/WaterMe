// swift-tools-version:5.5

//
//  Created by Jeffrey Bergier on 2021/12/30.
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
    name: "Datum",
    platforms: [.iOS(.v15), .macOS(.v12), .watchOS(.v8)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Datum",
            targets: ["Datum"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(path: "../Model"),
        .package(path: "../Umbrella")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Datum",
            dependencies: [
                .byNameItem(name: "Model", condition: nil),
                .byNameItem(name: "Umbrella", condition: nil)
            ],
            resources: [
                .copy("Resources/SampleDB.sqlite"),
                .copy("Resources/SampleDB.sqlite-wal")
            ]),
        .testTarget(
            name: "DatumTests",
            dependencies: ["Datum"])
    ]
)
