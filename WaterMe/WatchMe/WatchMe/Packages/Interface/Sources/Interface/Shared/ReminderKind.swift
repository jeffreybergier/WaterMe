//
//  Created by Jeffrey Bergier on 2022/02/06.
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
import Umbrella
import Style

internal struct ReminderKind: View {

    internal let kind: Model.ReminderKind
    @Style.ReminderKind private var style
    @EnvironmentBundle<ImageBundle> private var image

    internal init(kind: Model.ReminderKind, style: Style.ReminderKind? = nil) {
        _style = style ?? .init()
        self.kind = kind
    }

    internal var body: some View {
        self.image.for(self.kind)
            .resizable()
            .scaledToFit()
            .modifier(self.style.treatment)
            .modifier(self.style.circle)
            .layoutPriority(0.1)
    }
}

#if DEBUG
struct ReminderKindWater: PreviewProvider {
    static var previews: some View {
        ReminderKind(kind: .water)
            .previewDevice("Apple Watch Series 5 - 40mm")
    }
}

struct ReminderKindFertilize: PreviewProvider {
    static var previews: some View {
        ReminderKind(kind: .fertilize)
            .previewDevice("Apple Watch Series 5 - 40mm")
    }
}

struct ReminderKindTrim: PreviewProvider {
    static var previews: some View {
        ReminderKind(kind: .trim)
            .previewDevice("Apple Watch Series 5 - 40mm")
    }
}

struct ReminderKindMist: PreviewProvider {
    static var previews: some View {
        ReminderKind(kind: .mist)
            .previewDevice("Apple Watch Series 5 - 40mm")
    }
}

struct ReminderKindMove: PreviewProvider {
    static var previews: some View {
        ReminderKind(kind: .move)
            .previewDevice("Apple Watch Series 5 - 40mm")
    }
}

struct ReminderKindOther: PreviewProvider {
    static var previews: some View {
        ReminderKind(kind: .other)
            .previewDevice("Apple Watch Series 5 - 40mm")
    }
}
#endif
