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
import Localize

internal struct VesselIcon: View {

    internal let icon: Model.VesselIcon?
    @Localize.VesselIcon private var text
    @Style.VesselIcon private var style

    internal init(icon: Model.VesselIcon?, style: Style.VesselIcon? = nil) {
        _style = style ?? .init()
        self.icon = icon
    }

    internal var body: some View {
        self.centerView
            .modifier(self.style.treatment)
            .modifier(self.style.circle)
            .layoutPriority(0.1)
    }

    @ViewBuilder private var centerView: some View {
        if let image = self.icon?.imageValue {
            Image(image)
                .resizable()
                .scaledToFill()
        } else {
            JSBText(self.text(\.placeholderIcon), text: self.icon?.stringValue)
                .font(self.style.font)
        }
    }
}

#if DEBUG
struct ReminderListGridCellVesselIconSmall: PreviewProvider {
    static var previews: some View {
        VesselIcon(icon: nil, style: .init(size: .small))
            .previewDevice("Apple Watch Series 5 - 40mm")
    }
}

struct ReminderListGridCellVesselIconMedium: PreviewProvider {
    static var previews: some View {
        VesselIcon(icon: .emoji("🐲"), style: .init(size: .medium))
            .previewDevice("Apple Watch Series 5 - 40mm")
    }
}

struct ReminderListGridCellVesselIconLarge: PreviewProvider {
    static var previews: some View {
        VesselIcon(icon: .emoji("🐲"), style: .init(size: .large))
            .previewDevice("Apple Watch Series 5 - 40mm")
    }
}

struct ReminderListGridCellVesselIconImage: PreviewProvider {
    static var imageData: Data {
        let url = Bundle.module.url(forResource: "TEST_IMAGE", withExtension: "jpeg")!
        let data = try! Data(contentsOf: url)
        return data
    }
    static var previews: some View {
        VesselIcon(icon: .image(self.imageData), style: .init(size: .large))
            .previewDevice("Apple Watch Series 5 - 40mm")
    }
}
#endif
