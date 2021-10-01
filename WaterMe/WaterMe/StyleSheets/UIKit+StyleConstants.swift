//
//  UIKit+StyleConstants.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/20/18.
//  Copyright © 2018 Saturday Apps.
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

import CropViewController
import UIKit
import AVFoundation

extension UIView {
    /// Animates in a normal way.
    /// Executes completion closure when animation completes.
    class func style_animateNormal(_ animations: @escaping () -> Void, completion: @escaping ((Bool) -> Void)) {
        self.animate(withDuration: UIApplication.style_animationDurationNormal,
                     delay: 0,
                     options: [],
                     animations: animations,
                     completion: completion)
    }
    /// Animates in a normal way.
    class func style_animateNormal(_ animations: @escaping () -> Void) {
        self.animate(withDuration: UIApplication.style_animationDurationNormal,
                     delay: 0,
                     options: [],
                     animations: animations,
                     completion: nil)
    }
    /// Animates in a slightly longer way than normal.
    /// Executes completion closure when animation completes.
    class func style_animateLong(_ animations: @escaping () -> Void, completion: @escaping ((Bool) -> Void)) {
        self.animate(withDuration: UIApplication.style_animationDurationLong,
                     delay: 0,
                     options: [],
                     animations: animations,
                     completion: completion)
    }
    /// Animates in a slightly longer way than normal.
    class func style_animateLong(_ animations: @escaping () -> Void) {
        self.animate(withDuration: UIApplication.style_animationDurationLong,
                     delay: 0,
                     options: [],
                     animations: animations,
                     completion: nil)
    }
}

extension ReminderHeaderCollectionReusableView {
    class func style_viewHeight(isAccessibilityCategory: Bool) -> CGFloat {
        switch isAccessibilityCategory {
        case true:
            return 74
        case false:
            return 44
        }
    }
}

extension ModalParentViewController {
    enum Style {
        static var grayViewColor: UIColor {
            let defaultColor = UIColor.black.withAlphaComponent(0.5)
            guard #available(iOS 13.0, *) else { return defaultColor }
            return UIColor { traits -> UIColor in
                return traits.userInterfaceStyleIsNormal
                    ? defaultColor
                    : UIColor.black.withAlphaComponent(0.8)
            }
        }
    }
}

extension UIVisualEffectView {
    @objc class func style_systemMaterial() -> UIVisualEffectView {
        let style: UIBlurEffect.Style
        if #available(iOS 13.0, *) {
            style = UIBlurEffect.Style.systemMaterial
        } else {
            style = .extraLight
        }
        let v = UIVisualEffectView(effect: UIBlurEffect(style: style))
        v.layer.cornerRadius = UIApplication.style_cornerRadius
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }
}

extension UIApplication {
    static let style_animationDurationLong: TimeInterval = 1.2
    static let style_animationDurationNormal: TimeInterval = 0.3
    static let style_cornerRadius: CGFloat = 12
    class func style_configure() {
        UIView.appearance().tintColor = Color.tint

        UIImageView.appearance(whenContainedInInstancesOf: [
            ReminderTableViewCell.self
        ]).tintColor = Color.textSecondary

        // For some reason these have to be separate in order for it to be effective.
        let types: [UIAppearanceContainer.Type] = [ReminderSummaryViewController.self,
                                                   ReminderSummaryPopoverBackgroundView.self]
        types.forEach {
            UIVisualEffectView
                .appearance(whenContainedInInstancesOf: [$0])
                .backgroundColor = Color.visuelEffectViewBackground
        }

        if #available(iOS 13.0, *) {
            // make sure navigation bars appear the legacy way
            let transparentAppearance = UINavigationBarAppearance()
            let defaultAppearance = UINavigationBarAppearance()
            transparentAppearance.configureWithTransparentBackground()
            defaultAppearance.configureWithDefaultBackground()
            UINavigationBar.appearance().compactAppearance = defaultAppearance
            UINavigationBar.appearance().standardAppearance = defaultAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = transparentAppearance
        } else {
            // make sure visual effect views have the legacy appearance
            // For some reason these have to be separate in order for it to be effective.
            let types: [UIAppearanceContainer.Type] = [ReminderSummaryViewController.self,
                                                       ReminderFinishDropTargetViewController.self]
            types.forEach {
                UIVisualEffectView
                    .appearance(whenContainedInInstancesOf: [$0])
                    .effect = UIBlurEffect(style: .extraLight)
            }
        }
    }
}

extension UINavigationBar {
    func style_forceDefaultAppearance() {
        guard #available(iOS 13.0, *) else { return }
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        self.compactAppearance = appearance
        self.standardAppearance = appearance
        self.scrollEdgeAppearance = appearance
    }
}

extension UIView {
    func style_configure() {
        // configure dark mode
        let ud = UserDefaults.standard
        if #available(iOS 13.0, *) {
            switch ud.darkMode {
            case .system:
                self.overrideUserInterfaceStyle = .unspecified
            case .forceLight:
                self.overrideUserInterfaceStyle = .light
            case .forceDark:
                self.overrideUserInterfaceStyle = .dark
            }
        }
    }
}

extension UIView {
    func style_setCornerRadius() {
        self.layer.cornerRadius = self.maxCornerRadius(withDesiredRadius: UIApplication.style_cornerRadius)
    }
}

extension UIWindow {
    func style_configureTemporaryReset() {
        let ud = UserDefaults.standard
        if #available(iOS 13.0, *) {
            switch ud.darkMode {
            case .system:
                self.backgroundColor = .systemBackground
            case .forceLight:
                self.backgroundColor = .white
            case .forceDark:
                self.backgroundColor = .black
            }
        } else {
            self.backgroundColor = .white
        }
    }

    func style_unconfigureTemporaryReset() {
        self.backgroundColor = nil
    }
}

extension ReminderSummaryViewController {
    static let style_leadingTrailingPadding: CGFloat = 8
    static let style_bottomPadding: CGFloat = style_leadingTrailingPadding
    static let style_topPadding: CGFloat = style_bottomPadding / 2
    static let style_tableViewSectionGap: CGFloat = 8
    static let style_tableViewHighlightAlpha: CGFloat = 0.1
    static let style_actionButtonSeparatorColor: UIColor = Color.tint.withAlphaComponent(0.2)
    static let style_primaryLabelSublabelSpacing: CGFloat = 4
}

extension DragTargetInstructionalView {
    static let style_animationDurationLong: TimeInterval = 2
    static let style_animationDurationNormal: TimeInterval = 1
    static let style_animationDelayLong: TimeInterval = 4
    static let style_animationDelayNormal: TimeInterval = 1
}

extension ReminderFinishDropTargetViewController {
    static let style_dropTargetViewCompactHeight: CGFloat = 88
    static let style_dropTargetViewCompactHeightAccessibilityTextSizeEnabled: CGFloat = 132
}

extension ReminderCollectionViewCell {
    static let style_emojiImageViewWidth: CGFloat = 100
    static let style_emojiImageViewWidthAccessibility: CGFloat = 170
}

extension UITableViewCell {
    static let style_labelCellTopPadding: CGFloat = 12
    static let style_labelCellBottomPadding: CGFloat = 12
    static let style_labelCellLeadingPadding: CGFloat = 16
    static let style_labelCellTrailingPadding: CGFloat = 16

    static let style_textFieldCellTopPadding: CGFloat = 7
    static let style_textFieldCellBottomPadding: CGFloat = 6
    static let style_textFieldCellLeadingPadding: CGFloat = 16
    static let style_textFieldCellTrailingPadding: CGFloat = 16
}

extension TextViewTableViewCell {
    static let style_cellHeightAccessibilityTextSizeEnabled: CGFloat = 400
    static let style_cellHeightAccessibilityTextSizeDisabled: CGFloat = 200
}

extension ReminderVesselIconTableViewCell {
    static let style_iconButtonHeightAccessibilityTextSizeEnabled: CGFloat = 280
    static let style_iconButtonHeightAccessibilityTextSizeDisabled: CGFloat = 140
}

extension AVPlayerItem {
    class func style_videoAsset(at url: URL, forDarkMode darkMode: Bool) -> AVPlayerItem {
        guard darkMode == true else { return .init(url: url) }

        guard
            let grayscaleFilter = CIFilter(name: "CIColorControls"),
            let invertFilter = CIFilter(name: "CIColorInvert")
        else {
            assertionFailure("Failed to load built-in CIFilters")
            return .init(url: url)
        }
        grayscaleFilter.setValue(NSNumber(value: 0), forKey: kCIInputSaturationKey)
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)

        item.videoComposition = .init(asset: asset) { request in
            let pass0 = request.sourceImage
            grayscaleFilter.setValue(pass0, forKey: kCIInputImageKey)
            guard let pass1 = grayscaleFilter.outputImage else {
                assertionFailure("Failed to apply basic filters")
                request.finish(with: pass0, context: nil)
                return
            }
            invertFilter.setValue(pass1, forKey: kCIInputImageKey)
            guard let pass2 = invertFilter.outputImage?.cropped(to: request.sourceImage.extent) else {
                assertionFailure("Failed to apply basic filters")
                request.finish(with: pass0, context: nil)
                return
            }
            request.finish(with: pass2, context: nil)
        }
        return item
    }
}

extension CloudSyncProgressView {
    enum Style {
        static let statusIconTextGap: CGFloat = -8
    }
}
