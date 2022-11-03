//
//  Created by Jeffrey Bergier on 2022/03/06.
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

import Foundation
import SwiftUI
import Umbrella
import Model

internal class ImageBundle: EnvironmentBundleProtocol {

    internal let bundle: Bundle = Bundle.module

    internal var camera: Image { self.image(named: Raw.camera)! }
    internal var reminderPaused: Image { Image(systemName: Raw.speakerZ) }
    internal var videoPortrait: URL { self.url(name: Raw.wateringPortrait, extension: "mov")! }
    internal var videoLandscape: URL { self.url(name: Raw.wateringLandscape, extension: "mov")! }

    internal init() {}

    internal func `for`(_ kind: Model.ReminderKind) -> Image {
        switch kind {
        case .water:
            return self.image(named: Raw.reminderKindWater)!
        case .fertilize:
            return self.image(named: Raw.reminderKindFertilize)!
        case .trim:
            return self.image(named: Raw.reminderKindTrim)!
        case .mist:
            return self.image(named: Raw.reminderKindMist)!
        case .move:
            return self.image(named: Raw.reminderKindMove)!
        case .other:
            return self.image(named: Raw.reminderKindOther)!
        }
    }
}

extension ImageBundle {
    fileprivate enum Raw {
        fileprivate static let reminderKindWater = "ReminderKindWater"
        fileprivate static let reminderKindFertilize = "ReminderKindFertilize"
        fileprivate static let reminderKindTrim = "ReminderKindTrim"
        fileprivate static let reminderKindMist = "ReminderKindMist"
        fileprivate static let reminderKindMove = "ReminderKindMove"
        fileprivate static let reminderKindOther = "ReminderKindOther"
        fileprivate static let speakerZ = "speaker.zzz"
        fileprivate static let camera = "Camera"
        fileprivate static let wateringLandscape = "WateringLandscape"
        fileprivate static let wateringPortrait = "WateringPortrait"
    }
}
