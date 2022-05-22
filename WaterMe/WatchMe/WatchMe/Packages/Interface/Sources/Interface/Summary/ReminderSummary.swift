//
//  Created by Jeffrey Bergier on 2022/01/23.
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
import Datum
import Nav
import Umbrella
import Style
import Localize

internal struct ReminderSummary: View {
    
    internal struct Presentation: ViewModifier {
        @NavGeneric private var nav
        func body(content: Content) -> some View {
            content
                .modifier(Alert(self.$nav.isError))
                .modifier(OnAppearErrorHandler())
        }
    }
    
    @ReminderEditQuery private var reminder: Reminder
    @VesselEditQuery private var vessel: Vessel
    
    @SizeClass private var size
    @Style.Form private var style
    @NavReminderList private var nav
    @Localize.ReminderSummary private var text
    @Environment(\.dismiss) private var dismiss
    
    // TODO: Hack due to broken SwiftUI navigation
    @State private var performOnDisappear: (() -> Void)?
    
    internal init(rID: Reminder.アイディ, vID: Vessel.アイディ) {
        _reminder = .init(id: rID)
        _vessel = .init(id: vID)
    }
    
    internal var body: some View {
        List {
            self.actionsUpper()
            self.sectionVessel()
            self.sectionReminder()
            self.sectionNote()
            self.actionsLower()
        }
        .onChange(of: self.reminder.isDeleted) { isDeleted in
            guard isDeleted else { return }
            self.dismiss()
        }
        .modifier(ForceListRowSeparatorHidden())
        .modifier(SizeSpecificNavigation(onDismiss: { self.dismiss() }))
        .onDisappear {
            self.performOnDisappear?()
            self.performOnDisappear = nil
        }
        .modifier(self.style.popoverControl)
    }
    
    @ViewBuilder private func sectionVessel() -> some View {
        Section {
            VesselIcon(icon: self.vessel.icon)
                .modifier(CenterModifier())
                .modifier(self.style.sectionPaddingTop)
            VStack(alignment: .leading,
                   spacing: self.style.subsectionDataVerticalSpacing)
            {
                Text(self.text(\.subsectionName))
                    .modifier(self.style.subsectionTitle)
                JSBText(self.text(\.subsectionDataNoName),
                        text: self.vessel.displayName)
                    .modifier(self.style.subsectionData)
                    .modifier(self.style.sectionPaddingBottom)
            }
        } header: {
            Text(self.text(\.sectionVessel))
                .modifier(self.style.sectionTitle)
        }
    }
    
    @ViewBuilder private func sectionReminder() -> some View {
        Section {
            VStack(alignment: .leading,
                   spacing: self.style.subsectionDataVerticalSpacing)
            {
                Text(self.text(\.subsectionLastPerformed))
                    .modifier(self.style.subsectionTitle)
                    .modifier(self.style.sectionPaddingTop)
                JSBText(self.text(\.subsectionDataNever),
                        text: self._text.subsectionDataLastPerformed(self.reminder.lastPerformDate))
                    .modifier(self.style.subsectionData)
            }
            VStack(alignment: .leading,
                   spacing: self.style.subsectionDataVerticalSpacing)
            {
                Text(self.text(\.subsectionRemindEvery))
                    .modifier(self.style.subsectionTitle)
                Text(self._text.subsectionDataRemindEvery(self.reminder.interval))
                    .modifier(self.style.subsectionData)
            }
            VStack(alignment: .leading,
                   spacing: self.style.subsectionDataVerticalSpacing)
            {
                Text(self.text(\.subsectionKind))
                    .modifier(self.style.subsectionTitle)
                if case .other = reminder.kind {
                    JSBText(self.text(\.subsectionPlaceholderKind),
                            text: self.reminder.kindDescription)
                        .modifier(self.style.subsectionData)
                } else {
                    Text(self._text.subsectionDataKind(self.reminder.kind))
                        .modifier(self.style.subsectionData)
                }
            }
            if case .move = self.reminder.kind,
               let location = self.reminder.kindDescription
            {
                VStack(alignment: .leading,
                       spacing: self.style.subsectionDataVerticalSpacing)
                {
                    Text(self.text(\.subsectionMoveTo))
                        .modifier(self.style.subsectionTitle)
                    Text(location)
                        .modifier(self.style.subsectionData)
                }
            }
            VStack(alignment: .leading,
                   spacing: self.style.subsectionDataVerticalSpacing)
            {
                Text(self.text(\.subsectionDueNext))
                    .modifier(self.style.subsectionTitle)
                JSBText(self.text(\.subsectionDataNow),
                        text: self._text.subsectionDataDueNext(self.reminder.nextPerformDate))
                    .modifier(self.style.subsectionData)
                    .modifier(self.style.sectionPaddingBottom)
            }
        } header: {
            Text(self.text(\.sectionReminder))
                .modifier(self.style.sectionTitle)
        }
    }
    
    @ViewBuilder private func sectionNote() -> some View {
        if let note = self.reminder.note {
            Section {
                Text(note)
                    .modifier(self.style.subsectionData)
                    .modifier(self.style.multilineLabelMaxHeight)
                    .modifier(self.style.sectionPaddingTop)
                    .modifier(self.style.sectionPaddingBottom)
            } header: {
                Text(self.text(\.sectionNotes))
                    .modifier(self.style.sectionTitle)
            }
        }
    }
    
    @ViewBuilder private func actionsUpper() -> some View {
        switch self.size.horizontal {
        case .small:
            self.actionsAll()
        case .medium, .large:
            EmptyView()
        }
    }
    
    @ViewBuilder private func actionsLower() -> some View {
        switch self.size.horizontal {
        case .small:
            EmptyView()
        case .medium, .large:
            self.actionsAll()
            Section {
                Button { self.dismiss() }
                 label: {
                     Text(self.text(\.buttonDismiss))
                         .modifier(ButtonModifier(role: .cancel))
                 }
            }
        }
    }
    
    @ViewBuilder private func actionsAll() -> some View {
        Section {
            Button {
                self.performOnDisappear = { self.nav.isWatering = .init([self.reminder.id]) }
                self.dismiss()
            } label: {
                Text(self.text(\.buttonMarkDone))
                    .modifier(ButtonModifier(role: .primary))
            }
            Button {
                self.performOnDisappear = { self.nav.isReminderEdit = .init(self.reminder.id) }
                self.dismiss()
            } label: {
                Text(self.text(\.buttonEditReminder))
                    .modifier(ButtonModifier(role: .normal))
            }
            Button {
                self.performOnDisappear = { self.nav.isVesselEdit = .init(self.vessel.id) }
                self.dismiss()
            } label: {
                Text(self.text(\.buttonEditPlant))
                    .modifier(ButtonModifier(role: .normal))
            }
        }
    }
}

fileprivate struct SizeSpecificNavigation: ViewModifier {
    
    fileprivate var onDismiss: () -> Void
    @SizeClass private var size
    @Localize.ReminderSummary private var text
    
    fileprivate func body(content: Content) -> some View {
        switch self.size.horizontal {
        case .small:
            NavigationView {
                content
                    .navigationTitle(self.text(\.title))
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button {
                                self.onDismiss()
                            } label: {
                                Text(self.text(\.buttonDismiss))
                                    .modifier(ButtonModifier(role: .primary))
                            }
                        }
                    }
            }
        case .medium, .large:
            content
        }
    }
}

