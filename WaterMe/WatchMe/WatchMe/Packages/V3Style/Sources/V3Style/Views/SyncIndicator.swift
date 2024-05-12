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
        case idle = 0, error, unavailable, syncing, idleSoon
    }
    
    public struct Localization {
        public let idle:        ActionLocalization
        public let error:       ActionLocalization
        public let unavailable: ActionLocalization
        public let syncing:     ActionLocalization
        public let idleSoon:    ActionLocalization

        public init(idle: ActionLocalization,
                    error: ActionLocalization,
                    unavailable: ActionLocalization,
                    syncing: ActionLocalization,
                    idleSoon: ActionLocalization)
        {
            self.idle = idle
            self.error = error
            self.unavailable = unavailable
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
            HStack {
                Spacer()
                self.composed
                    .opacity(self.opacity)
                    .scaleEffect(self.scale, anchor: .top)
                    .padding(.top, self.padding)
                Spacer()
            }
            Spacer()
        }
        .animation(.default, value: self.state)
    }
    
    private var composed: some View {
        ActionStyleSyncIndicator.action(text: self.localization).button {
            self.action(self.state)
        }
        .buttonStyle(.borderedProminent)
        .font(.largeTitle)
        .disabled(self.disabled)
        .frame(maxWidth: self.indicatorWidth)
    }
    
    private var indicatorWidth: CGFloat? {
        switch self.state {
        case .error, .unavailable: return nil
        case .idle, .syncing, .idleSoon: return 72
        }
    }
    
    private var localization: ActionLocalization {
        switch self.state {
        case .error:       return self.configuration.error
        case .unavailable: return self.configuration.unavailable
        case .syncing:     return self.configuration.syncing
        case .idleSoon:    return self.configuration.idleSoon
        case .idle:        return self.configuration.idle
        }
    }
    
    private var disabled: Bool {
        switch self.state {
        case .idle, .syncing, .idleSoon: return true
        case .error, .unavailable:       return false
        }
    }
    
    private var scale: CGSize {
        switch self.state {
        case .error, .unavailable, .syncing, .idleSoon:
            return .init(width: 1, height: 1)
        case .idle:
            return .init(width: 0.5, height: 0.5)
        }
    }
    
    private var padding: CGFloat {
        switch self.state {
        case .error, .unavailable, .syncing, .idleSoon:
            return 0.0
        case .idle:
            return -15.0
        }
    }
    
    private var opacity: CGFloat {
        switch self.state {
        case .error, .unavailable, .syncing, .idleSoon:
            return 1.0
        case .idle:
            return 0.0
        }
    }
}

internal struct SyncIndicatorModifier: ViewModifier {
    internal func body(content: Content) -> some View {
        ZStack {
            Color.gray
                .clipShape(Capsule())
            content
                .padding(8)
                .layoutPriority(1.1)
        }
    }
}
