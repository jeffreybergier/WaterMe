//
//  Created by Jeffrey Bergier on 2022/11/06.
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
import V3Nav
import V3Model
import V3Datum
import V3Style
import V3Localize

internal struct ShareList: View {
    
    @V3Style.ShareList private var style
    @V3Localize.ShareList private var text
    
    @Nav private var nav
    @ShareListQuery private var data
    
    internal init() { }
    
    internal var body: some View {
        self.data.view {
            List($0, id: \.self, selection: self.$nav.detail.isPresented) {
                Row($0)
            }
        } onEmpty: {
            self.text.noContent.action(style: self.style.row).label
        }
        .navigationTitle(self.text.title)
        .onChange(of: self.data.count, initial: true) { _, newCount in
            guard newCount == 1, self.nav.detail.isPresented == nil else { return }
            self.nav.detail.isPresented = self.data.first
        }
        // Uncomment if fake data is needed
        .modifier(DEBUG_DataModifier())
    }
}

#if DEBUG
fileprivate struct DEBUG_DataModifier: ViewModifier {
    
    private static let delay: TimeInterval = 1
    private let resetCount: Int = 15
    
    @Controller private var controller
    @DEBUG_VesselListQuery private var allVessels
    
    @State private var vesselIDs: Set<Vessel.Identifier> = []
    private let timer = Timer.publish(every: delay, on: .main, in: .common).autoconnect()
    
    func body(content: Content) -> some View {
        content
            .onReceive(self.timer) { _ in
                if vesselIDs.count < self.resetCount {
                    let newVesselID = self.controller.createVessel().value
                    _ = newVesselID.map { self.vesselIDs.insert($0) }
                    NSLog("Created Vessel: \(String(describing: newVesselID?.id))")
                } else {
                    _ = self.controller.delete(Set(self.allVessels.data))
                    self.vesselIDs = []
                    NSLog("Deleted All Vessels: \(self.allVessels.data.count)")
                }
            }
            .onAppear() {
                _ = self.controller.delete(Set(self.allVessels.data))
                self.vesselIDs = []
                NSLog("Deleted All Vessels: \(self.allVessels.data.count)")
            }
    }
}
#endif
