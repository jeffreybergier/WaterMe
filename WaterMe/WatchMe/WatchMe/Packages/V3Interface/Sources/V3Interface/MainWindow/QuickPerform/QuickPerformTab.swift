//
//  Created by Jeffrey Bergier on 2023/06/17.
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

#if os(watchOS)

import SwiftUI
import Umbrella
import V3Model
import V3Datum
import V3Nav
import V3Localize
import V3Style

extension QuickPerform {
    internal struct Tab<C: RandomAccessCollection<Reminder.Identifier>>: View {
        
        @V3Style.QuickPerform private var style
        @V3Localize.QuickPerform private var text
        
        @Binding private var onTap: V3Nav.QuickPerform.Hamburger
        
        private let data: C
        private let section: Reminder.Section
        
        internal init(data: C,
                      section: Reminder.Section?,
                      onTap: Binding<V3Nav.QuickPerform.Hamburger>)
        {
            self.data = data
            self.section = section ?? .lateAndToday
            _onTap = onTap
        }
        
        internal var body: some View {
            self.data.view { data in
                Button {
                    self.onTap.isPresented = true
                    self.onTap.selection = Set(data)
                } label: {
                    Render(data: data)
                }
                .buttonStyle(.plain)
            }
            .navigationTitle(self.navigationTitle)
        }
        
        private var navigationTitle: LocalizedString {
            switch self.section {
            case .lateAndToday:
                return self.text.sectionTitleLateAndToday
            case .tomorrow:
                return self.text.sectionTitleTomorrow
            case .late, .today, .thisWeek, .later, .disabled:
                fatalError("Unsupported Configuration")
            }
        }
    }
}

#endif
