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
import V3Model
import V3Datum
import V3Style
import V3Localize

extension VesselEdit {
    internal struct LibraryPicker: View {
        
        @VesselQuery private var vessel
        @Selection private var selection
        
        @V3Style.VesselEdit.LibraryPicker private var style
        @V3Localize.VesselEdit.LibraryPicker private var text
        
        @State private var temp_cropOutput: Data?
        
        private let id: Vessel.Selection.Element
        
        internal init(id: Vessel.Selection.Element) {
            self.id = id
        }
        
        internal var body: some View {
            Group {
                switch self.selection {
                case .step1_user_presentLibrary:
                    PhotosPicker("Open Photo Library",
                                 selection: self.$selection,
                                 matching: .images,
                                 preferredItemEncoding: .compatible)
                case .step2_system_loadPhoto:
                    ProgressView()
                case .step3_user_cropPhoto(let data):
                    PhotoCropper(input: data, output: self.$temp_cropOutput)
                case .step4_system_savePhoto(let data):
                    fatalError()
                }
            }
            .navigationTitle(self.text.title)
            .onLoadChange(of: self.id) {
                _vessel.setIdentifier($0)
            }
            .onChange(of: self.$selection.wrappedValue) { raw in
                Task {
                    guard let data = try? await raw?.loadTransferable(type: Data.self) else { return }
                    self.selection = .step3_user_cropPhoto(data)
                }
            }
        }
    }
}

public struct PhotoCropper: View {
    
    @State private var offset: CGSize = .zero
    @State private var scale:  CGFloat = 1
    
    @Binding private var output: Data?
    private let input: Data
    
    public init(input: Data, output: Binding<Data?>) {
        self.input = input
        _output = output
    }
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(data: self.input)!
                    .layoutPriority(-1)
                    .coordinateSpace(name: "Image")
                    .offset(self.offset)
                    .scaleEffect(self.scale)
                Rectangle()
                    .stroke(lineWidth: 4)
                    .coordinateSpace(name: "Crop")
                    .foregroundColor(.red)
                    .aspectRatio(1, contentMode: .fit)
                    .padding()
                VStack {
                    Text(String(describing: geo.frame(in: .named("Image"))))
                    Text(String(describing: geo.frame(in: .named("Crop"))))
                    Text(String(describing: self.offset))
                    Text(String(describing: self.scale))
                }
            }
        }
        .gesture(self.gestureDrag)
        .gesture(self.gestureMag)
    }
    
    private var gestureDrag: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                self.offset.width += value.location.x - value.startLocation.x
                self.offset.height += value.location.y - value.startLocation.y
            }
    }
    
    private var gestureMag: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                print(value)
                self.scale = value
            }
    }
}
