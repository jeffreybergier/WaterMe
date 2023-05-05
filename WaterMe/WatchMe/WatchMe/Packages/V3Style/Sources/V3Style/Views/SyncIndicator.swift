//
//  Created by Jeffrey Bergier on 2023/05/05.
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

public struct SyncIndicator: View {
    
    public typealias Action = (Visibility) -> Void
    
    public enum Visibility: Int {
        case idle = 0, error, syncing, idleSoon
    }
    
    public struct Localization {
        public let idle:     ActionLocalization
        public let error:    ActionLocalization
        public let syncing:  ActionLocalization
        public let idleSoon: ActionLocalization
        public init(idle: ActionLocalization,
                    error: ActionLocalization,
                    syncing: ActionLocalization,
                    idleSoon: ActionLocalization)
        {
            self.idle = idle
            self.error = error
            self.syncing = syncing
            self.idleSoon = idleSoon
        }
    }
    
    private let action: Action
    private let configuration: Localization
    private let state: Visibility
    
    public init(state: Visibility,
                configuration: Localization,
                action: @escaping Action)
    {
        self.state = state
        self.configuration = configuration
        self.action = action
    }
    
    public var body: some View {
        VStack {
            self.composed
                .font(.largeTitle)
                .opacity(self.opacity)
                .scaleEffect(self.scale, anchor: .top)
                .padding(.top, self.padding)
            Spacer()
        }
        .animation(.default, value: self.state)
    }
    
    private var composed: some View {
        Button {
            self.action(self.state)
        } label: {
            ZStack {
                Color.gray
                    .clipShape(Capsule())
                self.image
                    .padding(8)
                    .layoutPriority(1.1)
            }
        }
        .buttonStyle(.plain)
    }
    
    private var image: Image {
        switch self.state {
        case .error:    return Image(systemName: "exclamationmark.icloud")
        case .syncing:  return Image(systemName: "arrow.clockwise.icloud")
        case .idleSoon: return Image(systemName: "checkmark.icloud")
        case .idle:     return Image(systemName: "checkmark.icloud")
        }
    }
    
    private var scale: CGSize {
        switch self.state {
        case .error:    return .init(width: 1, height: 1)
        case .syncing:  return .init(width: 1, height: 1)
        case .idleSoon: return .init(width: 1, height: 1)
        case .idle:     return .init(width: 0.5, height: 0.5)
        }
    }
    
    private var opacity: CGFloat {
        switch self.state {
        case .error:    return 1.0
        case .syncing:  return 1.0
        case .idleSoon: return 1.0
        case .idle:     return 0.0
        }
    }
    
    private var padding: CGFloat {
        switch self.state {
        case .error:    return 15
        case .syncing:  return 15
        case .idleSoon: return 15
        case .idle:     return 0.0
        }
    }
}
