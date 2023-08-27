//
//  Created by Jeffrey Bergier on 2022/12/03.
//
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
import PhotosUI
import Umbrella

extension VesselEdit.LibraryPicker {
    @propertyWrapper
    public struct Selection: DynamicProperty {
        
        // swiftlint:disable:next nesting
        public enum Value: Equatable {
            case step1_user_presentLibrary
            case step2_system_loadPhoto(PhotosPickerItem)
            case step3_user_cropPhoto(Data)
            case step4_system_savePhoto(Data)
            
            public init(_ pickerItem: PhotosPickerItem?) {
                guard let pickerItem else { self = .step1_user_presentLibrary; return; }
                self = .step2_system_loadPhoto(pickerItem)
            }
            
            public var pickerItemValue: PhotosPickerItem? {
                guard case .step2_system_loadPhoto(let item) = self else { return nil }
                return item
            }
        }
        
        @State private var value: Value = .step1_user_presentLibrary
        
        public var wrappedValue: Value {
            get { self.value }
            nonmutating set { self.value = newValue }
        }
        
        public var projectedValue: Binding<PhotosPickerItem?> {
            self.$value.map(get: { $0.pickerItemValue },
                            set: { .init($0) })
        }
        
        public init() { }
    }
}
