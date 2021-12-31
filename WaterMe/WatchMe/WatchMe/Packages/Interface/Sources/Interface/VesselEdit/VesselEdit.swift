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
import Datum

internal struct VesselEdit: View {
    
    @Binding var nav: Nav
    @ReminderVesselQuery var vessel: ReminderVessel
    
    internal init(uuid: String, nav: Binding<Nav>, controller: AnyController) {
        _nav = nav
        _vessel = ReminderVesselQuery(uuid: uuid, controller: controller)
    }
    
    internal var body: some View {
        Form {
            Section(header: Text("Photo")) {
                switch self.vessel.icon {
                case .none:
                    Text("Nothing")
                case .emoji(let emoji):
                    Text(emoji)
                case .image(let image):
                    Image(uiImage: image)
                }
            }
            Section(header: Text("Name")) {
                TextField("Plant Name", text: self.$vessel.displayName ?? "-1")
            }
            Section(header: Text("Reminders")) {
                Text("// TODO: Coming Soon")
            }
            Section(header: Text("Siri Shortcut")) {
                Text("// TODO: Coming Soon")
            }
        }
        .navigationTitle("Edit Plant")
        .toolbar {
            Button("Done") { self.nav = .list(.none) }
        }
    }
}

extension VesselEdit {
    internal struct Pres: ViewModifier {
        let uuid: String
        @Binding var nav: Nav
        @EnvironmentObject private var controller: AnyController
        func body(content: Content) -> some View {
            content
                .sheet(isPresented: Binding(get: { true }, set: { _ in self.nav = .list(.none) }), onDismiss: nil) {
                    VesselEdit(uuid: self.uuid, nav: self.$nav, controller: self.controller)
                }
        }
    }
}
