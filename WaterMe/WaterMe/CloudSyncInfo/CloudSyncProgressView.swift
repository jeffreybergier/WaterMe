//
//  CloudSyncProgressView.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 2021/05/04.
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

import UIKit
import Calculate
import Datum

class CloudSyncProgressView: ZStackView {
    
    /// Sends the progress view and a closure to complete when done with performing lifecycle changes
    /// Pass true in closure to mark the item as able to be completed and false to indicate it could not be completed
    typealias LifecycleDelegate = (CloudSyncProgressView, ((Bool) -> Void)?) -> Void
    
    enum Lifecycle {
        case show, hide, present(UserFacingError, UIButton)
    }
    
    private enum State {
        case idle, syncing, error, unavailable
    }
    
    private let idleButton        = UIButton(type: .system)
    private let syncingButton     = UIButton(type: .system)
    private let errorButton       = UIButton(type: .system)
    private let unavailableButton = UIButton(type: .system)
    private var progressToken: Any?
    private var lastError: UserFacingError?
    private var lastErrorResetTimer: Timer?
    private var syncProgressActivityTimer: Timer?
    
    private let _progress: Any?
    @available(iOS 13.0, *)
    private var progress: AnyContinousProgress<GenericInitializationError, CloudKitSyncError>? {
        return _progress as? AnyContinousProgress<GenericInitializationError, CloudKitSyncError>
    }
    
    private var state: State = .idle {
        didSet {
            let view: UIView
            switch self.state {
            case .idle:
                view = self.idleButton
            case .syncing:
                view = self.syncingButton
            case .error:
                view = self.errorButton
            case .unavailable:
                view = self.unavailableButton
            }
            self.bringArrangedSubviewToFront(view)
        }
    }
    
    var lifecycleDelegate: LifecycleDelegate? {
        didSet {
            self.lastError = nil
            self.activateTimer()
        }
    }
    private(set) var lifecycle: Lifecycle = .show {
        didSet {
            self.lifecycleDelegate?(self,
                                    { [weak self] _ in
                                        self?.lastError = nil
                                        self?.activateTimer()
                                    })
        }
    }
    
    init(controller: BasicController?) {
        
        defer {
            self.animationDelegate = self
            self.addArrangedSubview(self.idleButton)
            self.addArrangedSubview(self.syncingButton)
            self.addArrangedSubview(self.errorButton)
            self.addArrangedSubview(self.unavailableButton)
            self.idleButton.alpha = 0
            self.syncingButton.alpha = 0
            self.errorButton.alpha = 0
            self.unavailableButton.alpha = 0
            self.idleButton.isEnabled = false
            self.syncingButton.isEnabled = false
            self.errorButton.addTarget(self, action: #selector(self.showNextError(_:)), for: .touchUpInside)
            self.unavailableButton.addTarget(self, action: #selector(self.showUnavailableError(_:)), for: .touchUpInside)
        }
        
        guard #available(iOS 14.0, *) else {
            self._progress = nil
            super.init(frame: .zero)
            return
        }
        
        self._progress = controller?.syncProgress
        super.init(frame: .zero)
        self.progressToken = controller?.syncProgress?.objectWillChange.sink { [weak self] in
            self?.activateTimer()
        }
    }
    
    private func updateLabels() {
        
        let edge: WritableKeyPath<UIEdgeInsets, CGFloat>
            = self.traitCollection.layoutDirection == .rightToLeft
            ? \.right
            : \.left
        self.idleButton.imageEdgeInsets[keyPath: edge] = Style.statusIconTextGap
        self.syncingButton.imageEdgeInsets[keyPath: edge] = Style.statusIconTextGap
        self.errorButton.imageEdgeInsets[keyPath: edge] = Style.statusIconTextGap
        self.unavailableButton.imageEdgeInsets[keyPath: edge] = Style.statusIconTextGap
        
        if #available(iOS 13.0, *) {
            self.idleButton.setImage(UIImage(systemName: "checkmark.icloud"), for: .normal)
            self.syncingButton.setImage(UIImage(systemName: "arrow.clockwise.icloud"), for: .normal)
            self.errorButton.setImage(UIImage(systemName: "exclamationmark.icloud"), for: .normal)
            self.unavailableButton.setImage(UIImage(systemName: "xmark.icloud"), for: .normal)
        }
        
        // Setting AttributedStrings on buttons breaks their automatic coloring
        // Setting font manually here
        
        self.idleButton.titleLabel?.font = Font.migratorSecondaryButton.attributes[.font] as? UIFont
        self.syncingButton.titleLabel?.font = Font.migratorSecondaryButton.attributes[.font] as? UIFont
        self.errorButton.titleLabel?.font = Font.migratorSecondaryButton.attributes[.font] as? UIFont
        self.unavailableButton.titleLabel?.font = Font.migratorSecondaryButton.attributes[.font] as? UIFont
        
        self.idleButton.setTitle(
            LocalizedString.statusSyncComplete,
            for: .normal
        )
        self.syncingButton.setTitle(
            LocalizedString.statusSyncInProgress,
            for: .normal
        )
        self.errorButton.setTitle(
            LocalizedString.statusSyncError,
            for: .normal
        )
        self.unavailableButton.setTitle(
            LocalizedString.statusSyncUnavailable,
            for: .normal
        )
    }
    
    private func activateTimer() {
        let invalidate = {
            self.syncProgressActivityTimer?.invalidate()
            self.syncProgressActivityTimer = nil
        }
        
        guard #available(iOS 14.0, *), let progress = self.progress else {
            invalidate()
            self.state = .unavailable
            self.lifecycle = .show
            return
        }
        
        guard self.syncProgressActivityTimer == nil else { return }
        defer { self.syncProgressActivityTimer?.fire() }
        
        self.syncProgressActivityTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true)
        { [weak self] _ in
            let error: UserFacingError? = progress.initializeError
                ?? progress.errorQ.popFirst()
                ?? self?.lastError
            guard error == nil else {
                invalidate()
                self?.lastError = error
                if self?.lastErrorResetTimer == nil {
                    // clear the error after 2 minutes
                    self?.lastErrorResetTimer = Timer.scheduledTimer(withTimeInterval: 120, repeats: false) { _ in
                        self?.lastError = nil
                        self?.lastErrorResetTimer?.invalidate()
                        self?.lastErrorResetTimer = nil
                        self?.activateTimer()
                    }
                }
                self?.state = .error
                self?.lifecycle = .show
                return
            }
            if progress.progress.fractionCompleted < 1 {
                self?.state = .syncing
                self?.lifecycle = .show
            } else {
                let oldState = self?.state
                // if the old state was an error
                // then we just want to hide
                // without first switching to idle
                if oldState == .error {
                    invalidate()
                    self?.lifecycle = .hide
                    return
                }
                self?.state = .idle
                if oldState == .idle {
                    // if the state was previously idle, then we want to let
                    // the timer invalidate and for the hide lifecycle to be fired.
                    // This makes it so the user sees the sync was completed
                    // 2 seconds before disappearing
                    invalidate()
                    self?.lifecycle = .hide
                }
            }
        }
    }
    
    @objc private func showNextError(_ sender: UIButton) {
        guard let error: UserFacingError = self.lastError else { return }
        self.lifecycle = .present(error, sender)
    }
    
    @objc private func showUnavailableError(_ sender: UIButton) {
        self.lifecycle = .present(Error.notAvailable, sender)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateLabels()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard self.window != nil else { return }
        self.updateLabels()
        let oldState = self.state
        self.state = oldState
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Loggable.default?.verbose()
    }
}

extension CloudSyncProgressView: ZStackViewAnimationDelegate {
    func didReorderArrangedSubviews(_ stackView: ZStackView) {
        UIView.style_animateNormal({
            stackView.arrangedSubviews.enumerated().forEach { index, view in
                if index == 0 {
                    view.alpha = 1
                    view.transform = .identity
                } else {
                    view.alpha = 0
                    view.transform = CGAffineTransform(translationX: -100, y: 0)
                }
            }
        }, completion: { _ in
            stackView.arrangedSubviews.first?.isUserInteractionEnabled = true
            stackView.arrangedSubviews.dropFirst().forEach { view in
                view.isUserInteractionEnabled = false
                view.transform = CGAffineTransform(translationX: +100, y: 0)
            }
        })
    }
}
