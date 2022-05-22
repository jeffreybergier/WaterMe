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
import Umbrella
import Nav
import Errors
import Localize

internal struct Alert: ViewModifier {
    
    @UFErrorQ private var errorQ
    @NavReminderList private var navReminderList
    @NavReminderEdit private var navReminderEdit
    @NavVesselEdit private var navVesselEdit
    @NavGeneric private var navGeneric
    
    @Binding private var error: UserFacingError?
    private var alertType = UFEAlert<LocalizeBundle>.self
    
    init(_ error: Binding<UserFacingError?>) {
        _error = error
    }
    
    func body(content: Content) -> some View {
        content.modifier(self.alertType.init(self.$error) { error in
            self.navReminderList.isError = nil
            self.navReminderEdit.isError = nil
            self.navVesselEdit.isError = nil
            self.navGeneric.isError = nil
            // TODO: See if its possible to safely ☝️ only remove this error
            self.errorQ.removeFirst()
        })
    }
}

internal struct OnAppearErrorHandler: ViewModifier {
    
    @NavReminderList private var navReminderList
    @NavReminderEdit private var navReminderEdit
    @NavVesselEdit private var navVesselEdit
    @NavGeneric private var navGeneric
    @UFErrorQ private var errorQ

    internal func body(content: Content) -> some View {
        content
            .onReceive(self.$errorQ.publisher) { _ in
                // Would prefer this to be in Interface file
                // but on Watch, it stops working when first
                // screen is not visible
                guard let error = self.errorQ.first else { return }
                self.navReminderList.append(error)
                self.navGeneric.append(error)
                self.navReminderEdit.append(error)
                self.navVesselEdit.append(error)
            }
            .onAppear {
                guard let error = self.errorQ.first else { return }
                self.navReminderList.append(error)
                self.navReminderEdit.append(error)
                self.navVesselEdit.append(error)
                self.navGeneric.append(error)
            }
    }
}
