//
//  ReminderDropTargetView.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 20/12/17.
//  Copyright © 2017 Saturday Apps.
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

import AVFoundation
import UIKit

class WateringAnimationPlayerView: UIView {

    @IBOutlet private weak var hairlineView: UIView?

    var hoverState: DragAndDropPlayerManager.HoverState {
        get { return self.videoManager.hoverState }
        set { self.videoManager.hoverState = newValue }
    }

    var finishedPlayingVideo: (() -> Void)?

    private let videoManager: DragAndDropPlayerManager = {
        let t1 = DragAndDropPlayerManager.Timings(start: CMTime(value: 3, timescale: 100),
                                                  hover: CMTime(value: 165, timescale: 100),
                                                  end: CMTime(value: 531, timescale: 100))
        let t2 = DragAndDropPlayerManager.Timings(start: CMTime(value: 3, timescale: 100),
                                                  hover: CMTime(value: 70, timescale: 100),
                                                  end: CMTime(value: 406, timescale: 100))
        let c = DragAndDropPlayerManager.Configuration(landscapeTimings: t1, portraitTimings: t2, forwardRate: 1.0, reverseRate: -1.0,
                                                       landscapeVideoURL: Bundle(for: WateringAnimationPlayerView.self).url(forResource: "iPhone5-landscape", withExtension: "mov", subdirectory: "Videos")!,
                                                       portraitVideoURL: Bundle(for: WateringAnimationPlayerView.self).url(forResource: "iPhone5-portrait", withExtension: "mov", subdirectory: "Videos")!)
        return DragAndDropPlayerManager(configuration: c)
    }()

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    private var videoLayer: AVPlayerLayer {
        // swiftlint:disable:next force_cast
        return self.layer as! AVPlayerLayer
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.videoManager.videoHiddenChanged = { [unowned self] hidden in
            UIView.style_animateNormal {
                self.alpha = hidden ? 0 : 1
            }
            guard hidden == true else { return }
            switch self.hoverState {
            case .drop, .noHover:
                self.finishedPlayingVideo?()
            case .hover:
                break
            }
        }

        self.videoLayer.videoGravity = .resizeAspect
        self.videoLayer.opacity = 0
        self.videoLayer.player = self.videoManager.player
    }

    func hardReset() {
        self.videoManager.hardReset()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        self.appearanceDidChange()
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        self.hairlineView?.backgroundColor = self.tintColor
    }

    private func appearanceDidChange() {
        self.videoLayer.backgroundColor = Color.systemBackgroundColor.cgColor
        self.videoManager.setTraitCollection(self.traitCollection)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.appearanceDidChange()
    }
}
