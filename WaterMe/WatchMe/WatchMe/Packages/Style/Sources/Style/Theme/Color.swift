//
//  Created by Jeffrey Bergier on 2022/02/10.
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
import VisualEffects

internal typealias ThemeColor = CompleteDictionary<Theme, Color>
internal typealias ButtonColor = CompleteDictionary<ButtonModifier.Action, ThemeColor>

internal enum Colors {
    static let app_tint: ThemeColor = [.light: Raw.purpleLight, .dark: Raw.purpleDark]
    static let app_destructive: ThemeColor = [.light: Raw.redLight, .dark: Raw.redDark]
    
    static let text_sectionTitle: ThemeColor              = [.light: Raw.text弱Light, .dark: Raw.text弱Dark]
    static let text_subsectionTitle: ThemeColor           = [.light: Raw.text弱Light, .dark: Raw.text弱Dark]
    static let text_subsectionData: ThemeColor            = [.light: Raw.text強Light, .dark: Raw.text強Dark]
    static let text_reminderListItemTitle: ThemeColor     = [.light: Raw.text強Light, .dark: Raw.text強Dark]
    static let text_reminderListItemSubtitle: ThemeColor  = [.light: Raw.text強Light, .dark: Raw.text強Dark]

    static let reminderKindIcon: ThemeColor               = app_tint
    static let reminderKindIconBackground: ThemeColor     = [.light: Raw.background2Light, .dark: Raw.background2Dark]
    static let reminderKindCircle: ThemeColor             = app_tint
    
    static let vesselKindEmojiBackground: ThemeColor      = [.light: .clear, .dark: .clear]
    static let vesselKindCircle: ThemeColor               = app_tint
    
    static let reminderListGridHeaderFallback: ThemeColor = [.light: Raw.background3Light, .dark: Raw.background3Dark]
    static let reminderListGridHeaderAccent: [Int: ThemeColor] = [
        0: [.light: Raw.brownLight,  .dark: Raw.brownDark],  // late
        1: [.light: Raw.greenLight,  .dark: Raw.greenDark],  // today
        2: [.light: Raw.greenLight,  .dark: Raw.greenDark],  // tomorrow
        3: [.light: Raw.purpleLight, .dark: Raw.purpleDark], // this week
        4: [.light: Raw.purpleLight, .dark: Raw.purpleDark], // later
        5: [.light: Raw.grayDark,    .dark: Raw.grayLight],  // disabled
    ]
    
    internal static let button: ButtonColor = [
        .primary: Colors.app_tint,
        .normal: Colors.app_tint,
        .cancel: Colors.app_tint,
        .destructive: Colors.app_destructive
    ]
}

extension Colors {
    internal enum Raw {
        internal static let redLight: Color    = .red
        internal static let redDark: Color     = .red
        internal static let brownLight: Color  = Color(red: 221/255.0, green: 158/255.0, blue: 95/255.0)
        internal static let brownDark: Color   = Color(red: 255/255.0, green: 163/255.0, blue: 72/255.0)
        internal static let greenLight: Color  = Color(red: 26/255.0, green: 188/255.0, blue: 156/255.0)
        internal static let greenDark: Color   = Color(red: 8/255.0, green: 228/255.0, blue: 185/255.0)
        internal static let purpleLight: Color = Color(red: 200/255.0, green: 129/255.0, blue: 242/255.0)
        internal static let purpleDark: Color  = Color(red: 192/255.0, green: 85/255.0, blue: 255/255.0)
        internal static let grayLight: Color   = Color(white: 0.6)
        internal static let grayDark: Color    = Color(white: 0.4)
        internal static let background1Light: Color = Color(white: 1)
        internal static let background1Dark: Color = Color(white: 0)
        internal static let background2Light: Color = Color(white: 1)
        internal static let background2Dark: Color = Color(white: 0)
        internal static let background3Light: Color = Color(white: 0.9)
        internal static let background3Dark: Color = Color(white: 0.1)
        
        internal static let purplePlusLight: Color = Color(red: 97/255.0, green: 46/255.0, blue: 128/255.0)
        internal static let purplePlusDark: Color = Color(red: 240/255.0, green: 216/255.0, blue: 255/255.0)
        
        internal static let text強Light: Color = Color(white: 0)
        internal static let text強Dark: Color = Color(white: 1)
        internal static let text中Light: Color = Color(white: 0.3)
        internal static let text中Dark: Color = Color(white: 0.7)
        internal static let text弱Light: Color = Color(white: 0.5)
        internal static let text弱Dark: Color = Color(white: 0.5)
    }
}

internal struct XPVisualEffectView: View {
    
    internal var fallback: ThemeColor
    internal var theme: Theme
    
    internal var body: some View {
        #if os(watchOS)
        return self.fallback[self.theme]
        #elseif os(iOS)
        switch self.theme {
        case .light:
            return VisualEffectBlur(blurStyle: .systemMaterialLight)
        case .dark:
            return VisualEffectBlur(blurStyle: .systemMaterialDark)
        }
        #else
        return VisualEffectBlur(material: .headerView)
        #endif
    }
}
