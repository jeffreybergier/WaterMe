//
//  Created by Jeffrey Bergier on 2022/01/02.
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
import Model
import Nav
import Datum
import Style
import Localize

internal struct VesselEmoji: View {

    internal struct Presentation: ViewModifier {
        @NavGeneric private var nav
        func body(content: Content) -> some View {
            content
                .modifier(Alert(self.$nav.isError))
                .modifier(OnAppearErrorHandler())
        }
    }

    @VesselEditQuery private var vessel: Vessel

    @Style.VesselEmoji private var style
    @Localize.VesselIcon private var text
    @Environment(\.dismiss) private var dismiss

    internal init(id: Vessel.アイディ) {
        _vessel = VesselEditQuery(id: id)
    }

    internal var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: self.style.columns)
                {
                    ForEach(Model.VesselEmoji) { item in
                        Button {
                            self.vessel.icon = .emoji(item)
                            self.dismiss()
                        } label: {
                            ZStack {
                                if self.vessel.icon?.stringValue == item {
                                    Color.accentColor
                                }
                                Text(item).font(Font.largeTitle)
                            }
                        }
                    }
                }
            }
            .navigationTitle(self.text(\.titleEmojiPicker))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(self.text(\.buttonCancel)) {
                        self.dismiss()
                    }
                    .modifier(ButtonModifier(role: .cancel))
                }
            }
        }
    }
}
