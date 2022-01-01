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
    
    @Nav private var nav
    @VesselEditQuery var vessel: Vessel
    @VesselEditReminderQuery var reminders: AnyRandomAccessCollection<Binding<Reminder>>
    
    internal init(id: Vessel.アイディ, controller: AnyController) {
        _vessel = VesselEditQuery(id: id, controller: controller)
        _reminders = VesselEditReminderQuery(id: id, controller: controller)
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
                List(self.reminders) { item in
                    Button   { self.nav = .init(.list(.vessel(.init(self.vessel.id, .reminder(item.id))))) }
                      label: { Text(item.wrappedValue.note ?? "-1") }
                }
            }
            Section(header: Text("Siri Shortcut")) {
                Text("// TODO: Coming Soon")
            }
        }
        .navigationTitle("Edit Plant")
        .toolbar {
            Button("Done") { self.nav = .init(.list(.none)) }
        }
        // TODO: Add sheet here for reminder presentation
    }
}
