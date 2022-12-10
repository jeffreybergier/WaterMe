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
        GeometryReader { geo in
            self.cropRectContainer {
                Spacer()
                ZStack {
                    Rectangle()
                        .stroke(lineWidth: 4)
                        .coordinateSpace(name: "Rectangle")
                        .foregroundColor(.red)
                        .aspectRatio(1, contentMode: .fit)
                        .padding()
                    VStack {
                        Text(String(describing: geo.frame(in: .named("Rectangle"))))
                        Text(String(describing: self.offset))
                        Text(String(describing: self.scale))
                    }
                }
                Spacer()
            }
        }
    }
    
    private var cropRectContainer: some Layout {
        VStackLayout()
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
