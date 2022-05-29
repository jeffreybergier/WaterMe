//
//  Created by Jeffrey Bergier on 2022/02/11.
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
import Style
import Localize
import Errors

// TODO: Perhaps move to umbrella with XPImage

extension Image {
    internal init(_ image: XPImage) {
        #if canImport(UIKit)
        self.init(uiImage: image)
        #else
        self.init(nsImage: image)
        #endif
    }
}

extension View {
    internal func xp_fullScreenCover<I: Identifiable, V: View>(
        item: Binding<I?>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (I) -> V
    ) -> some View
    {
        #if os(macOS)
        return self.sheet(item: item, onDismiss: onDismiss, content: content)
        #else
        return self.fullScreenCover(item: item, onDismiss: onDismiss, content: content)
        #endif
    }

    internal func xp_popover<I: Identifiable, V: View>(
        item: Binding<I?>,
        @ViewBuilder content: @escaping (I) -> V
    ) -> some View
    {
        #if os(watchOS)
        return self.sheet(item: item, content: content)
        #else
        return self.popover(item: item, content: content)
        #endif
    }
}

internal struct ForceNavigationBarTitleDisplayModeInline: ViewModifier {
    internal func body(content: Content) -> some View {
        #if os(macOS)
        return content
        #else
        return content.navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

internal struct ForceListRowSeparatorHidden: ViewModifier {
    internal func body(content: Content) -> some View {
        #if os(iOS)
        return content.listRowSeparator(.hidden)
        #else
        return content
        #endif
    }
}

internal struct ForceNavigationViewStyleStack: ViewModifier {
    internal func body(content: Content) -> some View {
        #if os(macOS)
        return content
        #else
        return content.navigationViewStyle(.stack)
        #endif
    }
}

internal struct XPSiriShortcuts: View {
    @Style.Form private var style
    @ViewBuilder internal var body: some View {
        #if os(iOS)
        Section {
            Text("// TODO: Coming Soon")
                .modifier(self.style.subsectionData)
                .modifier(self.style.sectionPaddingBottom)
                .modifier(self.style.sectionPaddingTop)
        } header: {
            Text("Siri Shortcut")
                .modifier(self.style.sectionTitle)
        }
        #else
        EmptyView()
        #endif
    }
}

internal struct XPDoneDeleteToolbar: ViewModifier {

    internal var onDone: () -> Void
    internal var onDelete: Errors.DeleteError

    @UFErrorQ private var errorQ
    @Localize.DoneDeleteToolbar private var text

    internal func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    // TODO: This is still not red
                    Button(role: .destructive) {
                        self.errorQ.append(self.onDelete)
                    } label: {
                        Text(self.text(\.buttonDelete))
                    }
                    .modifier(Style.ButtonModifier(role: .destructive))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        self.onDone()
                    } label: {
                        Text(self.text(\.buttonDone))
                    }
                    .modifier(Style.ButtonModifier(role: .primary))
                }
            }
    }
}
