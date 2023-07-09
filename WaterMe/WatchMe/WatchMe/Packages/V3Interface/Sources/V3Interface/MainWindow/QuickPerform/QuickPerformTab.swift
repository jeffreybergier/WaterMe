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

import SwiftUI
import Umbrella
import V3Model
import V3Datum
import V3Nav
import V3Localize
import V3Style

internal struct QuickPerformTab: View {
    
    @Nav private var nav
    @Controller private var controller
    @ErrorStorage private var errors
    
    @ReminderListQuery private var query
    
    @V3Style.QuickPerform private var style
    @V3Localize.QuickPerform private var text
    
    private let id: Share.Identifier
    private let section: Reminder.Section
    
    internal init(_ id: Share.Identifier, section: Reminder.Section) {
        self.id = id
        self.section = section
        _query = .init(section)
    }
    
    internal var body: some View {
        self.query.data.view { data in
            QuickPerform3Up(identifiers: Set(data.prefix(3)))
        } onEmpty: {
            Text("// TODO: All Done Here")
        }
        .navigationTitle(self.navigationTitle)
        .containerBackground(self.containerBackground.gradient, for: .tabView)
        .onChange(of: self.id, initial: true) { _, shareID in
            self.query.filter = .share(shareID)
        }
    }
    
    private func perform(selection: Reminder.Selection) {
        let result = self.controller.appendNewPerformToReminders(with: selection)
        switch result {
        case .failure(let error):
            self.errors.append(error)
        case .success:
            self.nav.stack.wateringAnimation()
        }
    }
    
    private var navigationTitle: LocalizedString {
        switch self.section {
        case .late:
            self.text.sectionTitleLate
        case .today:
            self.text.sectionTitleToday
        case .tomorrow:
            self.text.sectionTitleTomorrow
        case .thisWeek:
            self.text.sectionTitleThisWeek
        case .later:
            self.text.sectionTitleLater
        case .disabled:
            self.text.sectionTitleDisabled
        }
    }
    
    private var containerBackground: Color {
        switch self.section {
        case .late:
            self.style.backgroundLate
        case .today:
            self.style.backgroundToday
        case .tomorrow:
            self.style.backgroundTomorrow
        case .thisWeek:
            self.style.backgroundThisWeek
        case .later:
            self.style.backgroundLater
        case .disabled:
            self.style.backgroundDisabled
        }
    }
}
