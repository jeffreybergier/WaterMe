//
//  Created by Jeffrey Bergier on 2022/11/06.
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
import V3Nav
import V3Model
import V3Datum
import V3Localize
import V3Style

internal struct ReminderGrid: View {
    
    @Nav private var nav
    @Controller private var controller
    @V3Style.ReminderGrid private var style
    @V3Localize.ReminderGrid private var text
    
    @ReminderGridQuery private var sections
    @Environment(\.codableErrorResponder) private var errorResponder
    
    private let id: Share.Identifier
    
    internal init(_ id: Share.Identifier) {
        self.id = id
    }
    
    internal var body: some View {
        ScrollView {
            LazyVGrid(columns: self.style.columns) {
                self.sections.late.view { data in
                    Section {
                        ForEach(data) { id in
                            Cell(id)
                        }
                    } header: {
                        Header(.late)
                    }
                }
                self.sections.today.view { data in
                    Section {
                        ForEach(data) { id in
                            Cell(id)
                        }
                    } header: {
                        Header(.today)
                    }
                }
                self.sections.tomorrow.view { data in
                    Section {
                        ForEach(data) { id in
                            Cell(id)
                        }
                    } header: {
                        Header(.tomorrow)
                    }
                }
                self.sections.thisWeek.view { data in
                    Section {
                        ForEach(data) { id in
                            Cell(id)
                        }
                    } header: {
                        Header(.thisWeek)
                    }
                }
                self.sections.later.view { data in
                    Section {
                        ForEach(data) { id in
                            Cell(id)
                        }
                    } header: {
                        Header(.later)
                    }
                }
                self.sections.disabled.view { data in
                    Section {
                        ForEach(data) { id in
                            Cell(id)
                        }
                    } header: {
                        Header(.disabled)
                    }
                }
            }
        }
        .modifier(self.toolbar)
        .onLoadChange(of: self.id) {
            _sections.setFilter(.share($0))
        }
    }
    
    private var toolbar: JSBToolbar {
        return JSBToolbar(
            title: self.text.title,
            done: self.text.addPlant,
            doneAction: {
                switch self.controller.createVessel() {
                case .success(let id):
                    self.nav.stack.edit(id)
                case .failure(let error):
                    self.errorResponder(error.encode)
                }
            }
        )
    }
}
