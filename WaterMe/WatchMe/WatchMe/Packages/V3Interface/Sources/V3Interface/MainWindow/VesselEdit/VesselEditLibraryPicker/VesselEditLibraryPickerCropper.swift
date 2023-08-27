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

/*
import SwiftUI

internal let style_maxWidth: CGFloat = 1536

extension VesselEdit.LibraryPicker {
    public struct Cropper: View {
        
        @State private var offset = CGSize.zero
        @Environment(\.displayScale) private var displayScale
        @Binding private var output: Data?
        private let input: Data
        private let image: CGImage
        
        public init(input: Data, output: Binding<Data?>) {
            _output = output
            self.input = input
            let provider = CGDataProvider(data: input as CFData)!
            self.image = CGImage(jpegDataProviderSource: provider,
                                 decode: nil,
                                 shouldInterpolate: false,
                                 intent: .defaultIntent)!
        }
        
        public var body: some View {
            ZStack(alignment: .topLeading) {
                self.background
                    .overlay(alignment: .topLeading) {
                        self.imageToCrop
                    }
                self.cropRect
                self.zoomButtons
            }
            .gesture(self.gestureDrag)
        }
        
        private var background: some View {
            Color.blue
                .ignoresSafeArea()
        }
        
        private var imageToCrop: some View {
            Image(data: self.input)!
                .frame(width: CGFloat(self.image.width), height: CGFloat(self.image.height))
                .offset(x: self.offset.width, y: self.offset.height)
        }
        
        private var cropRect: some View {
            Rectangle()
                .stroke(lineWidth: 10)
                .foregroundColor(.red)
//                .frame(width: style_maxWidth / self.displayScale,
//                       height: style_maxWidth / self.displayScale)
                .frame(width: 200,
                       height: 200)
//                .transformEffect(CGAffineTransform(scaleX: 0.5, y: 0.5))
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
                    Button("➖") { /* self.offset.scale -= 0.1 */ }
                    Button("➕") { /* self.offset.scale += 0.1 */}
                    Spacer()
                }
                .font(.title)
            }
        }
    }
}

extension CGSize {
    internal func multiply(by factor: CGFloat) -> CGSize {
        .init(width: self.width * factor, height: self.height * factor)
    }
}

extension CGRect {
    internal func multiply(by factor: CGFloat) -> CGRect {
        .init(x: self.origin.x * factor, y: self.origin.y * factor,
              width: self.size.width * factor, height: self.size.height * factor)
    }
}

*/
