//
//  Created by Jeffrey Bergier on 2023/01/29.
//  Copyright © 2023 Saturday Apps.
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
import AVFoundation
import CoreLocation
import UserNotifications

@MainActor
@propertyWrapper
public struct DevicePermissions: DynamicProperty {
    
    public enum State {
        case denied, allowed, requestable, incapable
        public var boolValue: Bool {
            switch self {
            case .allowed: return true
            case .denied, .requestable, .incapable: return false
            }
        }
    }
    
    public struct Value {
        public var camera:  State = .denied
        public var library: State = .denied
        public var locate:  State = .denied
        public var notify:  State = .denied
    }
    
    @StateObject private var observable = Observable()
    
    public init() { }
    
    public var wrappedValue: Value {
        self.observable.value
    }
}

extension DevicePermissions {
    
    @MainActor
    internal class Observable: NSObject, ObservableObject, CLLocationManagerDelegate {
        
        @Published internal var value: Value = .init()
        private let locationManager = CLLocationManager()
        
        internal override init() {
            super.init()
            self.updateCamera()
            self.updateLibrary()
            self.updateNotify()
            self.locationManager.delegate = self
        }
        
        private func updateCamera() {
            #if os(watchOS)
            self.value.camera = .incapable
            #else
            switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
            case .authorized:
                self.value.camera = .allowed
            case .notDetermined:
                self.value.camera = .requestable
            case .denied, .restricted:
                fallthrough
            @unknown default:
                self.value.camera = .denied
            }
            #endif
        }
        
        private func updateLibrary() {
            // TODO: PhotosPicker now works on watchOS
            self.value.library = .denied
        }
        
        @objc nonisolated internal func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            let authorizationStatus = manager.authorizationStatus
            MainActor.assumeIsolated {
                switch authorizationStatus {
                case .notDetermined:
                    self.value.locate = .requestable
                case .restricted:
                    self.value.locate = .denied
                case .denied:
                    self.value.locate = .denied
                case .authorizedAlways:
                    self.value.locate = .allowed
                case .authorizedWhenInUse:
                    self.value.locate = .allowed
                @unknown default:
                    self.value.locate = .denied
                }
            }
        }
        
        private func updateNotify() {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    switch settings.authorizationStatus {
                    case .notDetermined:
                        self.value.notify = .requestable
                    case .denied:
                        self.value.notify = .denied
                    case .authorized:
                        self.value.notify = .allowed
                    case .provisional:
                        self.value.notify = .requestable
                    case .ephemeral:
                        self.value.notify = .requestable
                    @unknown default:
                        self.value.notify = .denied
                    }
                }
            }
        }
    }
}
