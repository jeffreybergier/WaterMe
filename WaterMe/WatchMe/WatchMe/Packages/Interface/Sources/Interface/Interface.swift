//
//  Created by Jeffrey Bergier on 2021/12/31.
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

import SwiftUI
import ServerlessLogger
import Umbrella
import Settings
import Datum
import Nav
import Errors
import Localize

public struct Interface: View {

    @NavGeneric private var navGeneric
    @NavVesselEdit private var navVesselEdit
    @NavReminderList private var navReminderList
    @NavReminderEdit private var navReminderEdit
    @UFErrorQ private var errorQ

    @State private var controllerLoadError: Datum.Error?
    @StateObject private var controllerEnvironment: ControllerProperty.Environment
    @ObservedObject private var datumErrorQueue = EnvironmentQueue<Datum.Error>.newEnvirementObject()

    // TODO: For debugging error propogation
    private let DEBUG_errorTimer = Timer.publish(every: 7, on: .main, in: .common).autoconnect()

    public init() {
        Loggable.configure()
        UserDefaults.standard.configure()
        let tuple = ControllerProperty.newEnvironment(of: UserDefaults.standard.controllerKind)
        _controllerEnvironment = .init(wrappedValue: tuple.0)
        _controllerLoadError = .init(wrappedValue: tuple.1)
    }

    public var body: some View {
        if let error = self.controllerLoadError {
            Text(error.title)
            Text(error.message)
        } else {
            ReminderList()
                .modifier(ReminderList.Presentation())
                .environmentObject(self.datumErrorQueue)
                .environmentObject(self.controllerEnvironment)
                .environmentObject(LocalizeBundle())
                .environmentObject(ImageBundle())
                .environment(\.managedObjectContext, self.controllerEnvironment.value!.__ENVONLY__managedObjectContext)
                .onReceive(self.datumErrorQueue.objectDidChange) { [datumErrorQueue] in
                    guard datumErrorQueue.value.isEmpty == false else { return }
                    self.errorQ.append(contentsOf: datumErrorQueue.value.map { $0 as UserFacingError })
                    datumErrorQueue.value = []
                }
                // TODO: For debugging error propogation
                .onReceive(self.DEBUG_errorTimer) { _ in
                    self.DEBUG_errorTimer.upstream.connect().cancel()
                    /*
                    self.errorQ.append(CameraPermissionError.libraryIncapable)
                    self.datumErrorQueue.value.append(.maintenanceDeleteOrphanedReminders)
                    self.errorQ.append(CameraPermissionError.cameraRestricted)
                    self.datumErrorQueue.value.append(.cannotDeleteLastReminder)
                    */
                }
        }
    }
}
