//
//  Created by Jeffrey Bergier on 2022/11/13.
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

internal struct VesselIcon: View {
    
    private let image: JSBImage?
    private let emoji: String?
    
    internal init(image: JSBImage?, emoji: String?) {
        self.image = image
        self.emoji = emoji
    }
    
    internal var body: some View {
        if let emoji {
            Text(emoji)
                .modifier(CircleModifierEmoji())
        } else if let image {
            Image(jsbImage: image)
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .frame(width: .thumbnailSmall, height: .thumbnailSmall, alignment: .center)
                .modifier(CircleModifierImage())
        } else {
            Text("🌸")
                .preference(key: isFallbackKey.self, value: true)
                .modifier(FallbackAlphaModifier())
                .modifier(CircleModifierEmoji())
        }
    }
    
}
