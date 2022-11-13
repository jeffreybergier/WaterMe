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

public struct Interface: Scene {
    
    @StateObject private var controller = Controller.newEnvironment(.local)
    @StateObject private var localizeBundle = LocalizeBundle()
    @StateObject private var launchConfiguration = SecretBox<(() -> Void)?>(UserDefaults.standard.configure)

    public init() {
        // TODO: this needs to be moved to somewhere that runs once
        // Accessing StateObject's object without being installed on a View. This will create a new instance each time.
        self.launchConfiguration.value?()
        self.launchConfiguration.value = nil
    }

    public var body: some Scene {
        WindowGroup {
            switch self.controller.value {
            case .success(let controller):
                MainWindow()
                    .environmentObject(self.controller)
                    .environmentObject(self.localizeBundle)
                    .environment(\.managedObjectContext, controller.context)
            case .failure(let error):
                Text(String(describing: error))
            }
        }
    }
}
