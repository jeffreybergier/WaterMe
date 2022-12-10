//
//  Created by Jeffrey Bergier on 2022/12/10.
//
//  MIT License
//
//  Copyright (c) 2021 Jeffrey Bergier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import SwiftUI

public struct PhotoCropper: View {
    
    @State private var offset: CGSize = .zero
    @State private var scale:  CGFloat = 1
    @StateObject private var processor = PhotoCropperImageProcessor()
    
    @Binding private var output: Data?
    private let input: Data
    
    public init(input: Data, output: Binding<Data?>) {
        self.input = input
        _output = output
    }
    
    public var body: some View {
        ZStack {
            self.background
            self.imageToCrop
            self.cropRect
            self.zoomButtons
        }
        .gesture(self.gestureDrag)
        .onChange(of: self.offset) {
            let output = self.processor.process(photo: self.input, offset: $0, zoom: self.scale)!
            dump(output)
        }
    }
    
    private var background: some View {
        Color.blue
            .ignoresSafeArea()
    }
    
    private var imageToCrop: some View {
        Image(data: self.input)!
            .ignoresSafeArea()
            .layoutPriority(-1)
            .offset(self.offset)
            .scaleEffect(self.scale)
    }
    
    private var cropRect: some View {
        Rectangle()
            .stroke(lineWidth: 4)
            .foregroundColor(.red)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                GeometryReader { geo in
                    // -> EmptyView does not work here. Assuming its optimized out
                    { () -> AnyView in
                        self.processor.cropRect = geo.frame(in: .global)
                        return AnyView(EmptyView())
                    }()
                }
            }
            .padding()
    }
    
    private var gestureDrag: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                self.offset.width += value.location.x - value.startLocation.x
                self.offset.height += value.location.y - value.startLocation.y
            }
    }
    
    private var zoomButtons: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button("➖") { self.scale -= 0.1 }
                Button("➕") { self.scale += 0.1}
                Spacer()
            }
            .font(.title)
        }
    }
}

fileprivate class PhotoCropperImageProcessor: ObservableObject {
    
    internal var cropRect: CGRect?
    
    fileprivate func process(photo input_data: Data, offset: CGSize, zoom: CGFloat) -> Data? {
        guard let input_cropRect = self.cropRect else { return nil }
        let input_ui = UIImage(data: input_data)!
        let input_cg = input_ui.cgImage!
        let input_rect = CGRect(origin: input_cropRect.origin, size: CGSize(width: input_cropRect.width + (offset.width * 2), height: input_cropRect.height + (offset.height * 2)))
        let output_cg = input_cg.cropping(to: input_rect)!
        let output_ui = UIImage(cgImage: output_cg)
        let output_data = output_ui.jpegData(compressionQuality: 0.7)!
        return output_data
    }
    
}
