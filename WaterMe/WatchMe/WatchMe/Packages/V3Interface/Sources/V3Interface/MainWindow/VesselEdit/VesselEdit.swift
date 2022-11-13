//
//  Created by Jeffrey Bergier on 2022/11/12.
//
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
import V3Model
import V3Datum

internal struct VesselEdit: View {
    
    @Nav private var nav
    
    @VesselQuery private var vessel
    @ReminderListQuery private var reminders
    
    private let id: Vessel.Identifier
    
    internal init(_ id: Vessel.Identifier) {
        self.id = id
    }
    
    internal var body: some View {
        self.$vessel.view { vessel in
            Form {
                Section {
                    if let image = vessel.wrappedValue.icon?.imageValue {
                        Image(jsbImage: image)
                    } else {
                        Text(String(describing: vessel.wrappedValue.icon?.stringValue))
                    }
                } header: {
                    Text("Photo")
                }
                Section {
                    TextField(text: vessel.displayName.compactMap(), prompt: nil) {
                        Text("Name")
                    }
                } header: {
                    Text("Name")
                }
                Section {
                    self.reminders.view { reminders in
                        ForEach(reminders) { id in
                            Button {
                                self.nav.edit(id)
                            } label: {
                                Text(String(describing: id))
                            }
                        }
                    } onEmpty: {
                        Text("Loading...")
                    }
                } header: {
                    Text("Reminders")
                }
                // TODO: Add Siri Shortcuts Here
            }
        } onNIL: {
            Text("Loading...")
        }
        .modifier(self.toolbar)
        .onLoadChange(of: self.id) {
            _vessel.setIdentifier($0)
            _reminders.setFilter(.vessel($0))
        }
    }
    
    private var toolbar: JSBToolbar {
        return JSBToolbar(
            title: "Edit Plant",
            delete: .init(title: "Delete"),
            deleteAction: {
                // TODO: Hookup error
                NSLog("Delete Me")
            }
        )
    }
}
