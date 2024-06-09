//
//  Created by Jeffrey Bergier on 2022/11/03.
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

import SwiftUI
import Umbrella
import V3Datum
import V3Settings
import V3Localize
import V3Logger

public struct Interface: Scene {
    
    private static let loggerDelegate = LoggerErrorDelegate()
    
    private static let launchConfiguration: Void = {
        UserDefaults.standard.configure()
        LoggableConfigure(with: Self.loggerDelegate)
        return ()
    }()
    
    // TODO: Make this read the actual setting
    @StateObject private var controller   = Controller.newEnvironment(.sync)
    @StateObject private var errorStorage = ErrorStorage.newEnvironment()
    
    private let localizeBundle = LocalizeBundle

    public init() {
        _ = Interface.launchConfiguration
    }

    public var body: some Scene {
        WindowGroup {
            switch self.controller.value {
            case .success(let controller):
                MainWindow()
                    .environmentObject(self.controller)
                    .environmentObject(self.errorStorage)
                    .environmentObject(controller.syncProgress)
                    .environment(\.bundle, self.localizeBundle)
                    .environment(\.managedObjectContext, controller.context)
                    .onReceive(controller.syncProgress.objectDidChange) { _ in
                        controller.syncProgress.value.errors.last?.log()
                    }
                    .onReceive(self.errorStorage.didAppendPub) { [weak errorStorage] id in
                        errorStorage?.error(for: id).map { $0.log() }
                    }
            case .failure(let error):
                Text(String(describing: error))
            }
        }
    }
}

import ServerlessLogger

private class LoggerErrorDelegate: ServerlessLoggerErrorDelegate {
    func logger(with configuration: ServerlessLoggerConfigurationProtocol, produced error: Logger.Error) {
        // Print ServerlessLogger Error in DEBUG mode only
        assert({ NSLog("LoggerErrorDelegate.error: \(error)"); return true }())
    }
}
