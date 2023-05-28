//
//  Created by Jeffrey Bergier on 2023/05/27.
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

internal struct QuickPerform: View {
    
    @Nav private var nav
    @Controller private var controller
    @ErrorStorage private var errors
    
    @ReminderListQuery(.late)     private var late
    @ReminderListQuery(.today)    private var today
    
    @V3Style.QuickPerform private var style
    @V3Localize.QuickPerform private var text
    
    private let id: Share.Identifier
    
    internal init(_ id: Share.Identifier) {
        self.id = id
    }
    
    internal var body: some View {
        ScrollView {
            self.style.late.action(text: .init(title: self.text.sectionTitleLate)).button {
                self.perform(selection: Set(self.late.data))
            }
            self.style.late.action(text: .init(title: self.text.sectionTitleToday)).button {
                self.perform(selection: Set(self.today.data))
            }
            self.style.late.action(text: .init(title: self.text.kindOther)).button {
                
            }
        }
        .onLoadChange(of: self.id) {
            self.late.filter     = .share($0)
            self.today.filter    = .share($0)
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
}
