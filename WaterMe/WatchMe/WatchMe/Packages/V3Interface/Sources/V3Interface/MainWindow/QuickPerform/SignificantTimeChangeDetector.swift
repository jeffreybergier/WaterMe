//
//  Created by Jeffrey Bergier on 2024/05/06.
//  Copyright © 2024 Saturday Apps.
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
import Foundation
#else
import UIKit
#endif
import SwiftUI
import Umbrella

internal class SignificantTimeChangeDetector: NotificationCenter.Observable {
    
    private static let notificationName: Notification.Name = {
        #if os(watchOS)
        return Notification.Name.NSCalendarDayChanged
        #else
        return UIApplication.significantTimeChangeNotification
        #endif
    }()
    
    internal init() {
        super.init(Self.notificationName)
    }
}
