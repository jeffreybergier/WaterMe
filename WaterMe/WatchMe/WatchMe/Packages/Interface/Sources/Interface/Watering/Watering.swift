//
//  Created by Jeffrey Bergier on 2021/12/31.
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
import Umbrella
import Datum
import Style
import Model
import Errors

internal struct Watering: View {
    
    let ids: [Reminder.アイディ]
    @State private var isPlaying = false

    @Style.Watering private var style
    @UFErrorQ private var errorQ
    @Environment(\.dismiss) private var dismiss
    @ControllerProperty private var controller
    @EnvironmentBundle<ImageBundle> private var image
    
    private var urls: CompleteDictionary<Size, URL> {
        [
            .small: self.image.videoLandscape,
            .medium: self.image.videoLandscape,
            .large: self.image.videoPortrait
        ]
    }
    
    internal var body: some View {
        Button(role: .cancel) {
            self.dismiss()
        } label: {
            Video(isPlaying: self.$isPlaying,
                  videoURL: self.urls[self.style.verticalSize])
            {
                self.isPlaying = false
                self.dismiss()
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear() {
            switch self.controller.appendNewPerformToReminders(with: self.ids) {
            case .success:
                self.isPlaying = true
            case .failure(let error):
                self.errorQ.append(error)
                self.dismiss()
            }
        }
    }
}
