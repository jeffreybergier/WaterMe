//
//  Created by Jeffrey Bergier on 2022/02/11.
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
import AVFoundation
import Combine

internal struct Video: View {
    @Binding internal var isPlaying: Bool
    internal var videoURL: URL
    internal var onFinish: () -> Void
    internal var body: some View {
        Video_native(isPlaying: self.$isPlaying,
                     videoURL: self.videoURL,
                     onFinish: self.onFinish)
    }
}

#if os(watchOS)
import WatchKit
fileprivate struct Video_native: WKInterfaceObjectRepresentable {
    
    @Binding fileprivate var isPlaying: Bool
    fileprivate var videoURL: URL
    fileprivate var onFinish: () -> Void
    
    fileprivate func makeWKInterfaceObject(context: Context) -> WKInterfaceInlineMovie {
        return HACK__WKInterfaceInlineMovie(onFinish: self.onFinish)
    }
    fileprivate func updateWKInterfaceObject(_ view: WKInterfaceInlineMovie, context: Context) {
        guard self.isPlaying == true else { return }
        view.setAutoplays(false)
        view.setLoops(false)
        view.setVideoGravity(.resizeAspectFill)
        view.setMovieURL(self.videoURL)
        view.playFromBeginning()
    }
}
import CoreMedia
fileprivate class HACK__WKInterfaceInlineMovie: WKInterfaceInlineMovie {
    
    fileprivate var onFinish: () -> Void
    private let name = NSNotification.Name("PlaybackStateDidChange")
    private var cancellable: Set<AnyCancellable> = []
    
    fileprivate init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
        super.init()
        NotificationCenter.default.publisher(for: self.name, object: nil).sink
        { [weak self] notification in
            guard let value = notification.userInfo?["CurrentPlaybackState"] as? NSNumber else {
                self?.cancellable.forEach { $0.cancel() }
                self?.cancellable = []
                return
            }
            guard value.intValue == 0 else { return }
            self?.cancellable.forEach { $0.cancel() }
            self?.cancellable = []
            self?.onFinish()
        }
        .store(in: &self.cancellable)
    }
}
#elseif os(iOS)
fileprivate struct Video_native: UIViewRepresentable {
    
    @Binding fileprivate var isPlaying: Bool
    fileprivate var videoURL: URL
    fileprivate var onFinish: () -> Void
    
    fileprivate func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        view.playerLayer.player = context.coordinator.player
        return view
    }
    
    fileprivate func updateUIView(_ uiView: PlayerView, context: Context) {
        guard self.isPlaying == true else { return }
        context.coordinator.player.play()
    }
    fileprivate func makeCoordinator() -> PlayerMonitor {
        return PlayerMonitor(videoURL: self.videoURL, onFinish: self.onFinish)
    }
}
fileprivate class PlayerView: UIView {
    fileprivate var playerLayer: AVPlayerLayer {
        return self.layer as! AVPlayerLayer
    }
    fileprivate override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }
}

#elseif os(macOS)
fileprivate struct Video_native: View {
    @Binding fileprivate var isPlaying: Bool
    fileprivate var videoURL: URL
    fileprivate var onFinish: () -> Void
    fileprivate var body: some View {
        Text("// TODO: Not implemented")
    }
}
#endif

fileprivate class PlayerMonitor {
    fileprivate let player: AVPlayer
    private var cancellable: Set<AnyCancellable> = []
    fileprivate init(videoURL: URL, onFinish: @escaping () -> Void) {
        let player = AVPlayer(url: videoURL)
        #if os(watchOS)
        #else
        player.allowsExternalPlayback = false
        #endif
        self.player = player
        player
            .publisher(for: \.rate, options: [.new])
            .sink { newRate in
                guard newRate == 0 else { return }
                onFinish()
            }
            .store(in: &self.cancellable)
    }
}
