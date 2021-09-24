//
//  ReminderFinishDropTargetViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 13/10/17.
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

import Datum
import UIKit

protocol ReminderFinishDropTargetViewControllerDelegate: AnyObject {
    func userDidCancelDrag(within: ReminderFinishDropTargetViewController)
    func userDidStartDrag(with values: [ReminderAndVesselValue],
                          within: ReminderFinishDropTargetViewController)
    func animateAlongSideDropTargetViewResize(within: ReminderFinishDropTargetViewController) -> (() -> Void)?
    func userDidPerformDrop(with reminders: [Identifier],
                            onTargetZoneWithin controller: ReminderFinishDropTargetViewController?)
}

class ReminderFinishDropTargetViewController: StandardViewController, HasBasicController, HasProController, UIDropInteractionDelegate {

    @IBOutlet private weak var instructionalView: DragTargetInstructionalView?
    @IBOutlet private weak var animationView: WateringAnimationPlayerView?
    @IBOutlet private weak var dropTargetView: UIView?
    @IBOutlet private weak var dropTargetViewHeightConstraint: NSLayoutConstraint?
    @IBOutlet private weak var dropTargetVisualEffectView: UIVisualEffectView? {
        didSet {
            self.dropTargetVisualEffectView?.clipsToBounds = true
            self.dropTargetVisualEffectView?.layer.cornerRadius = UIApplication.style_cornerRadius
        }
    }

    var basicRC: BasicController?
    var proRC: ProController?
    weak var delegate: ReminderFinishDropTargetViewControllerDelegate?
    var dropTargetViewHeight: CGFloat {
        return self.dropTargetViewHeightConstraint?.constant ?? 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        self.dropTargetView?.addInteraction(UIDropInteraction(delegate: self))
        self.animationView?.finishedPlayingVideo = { [unowned self] in
            self.updateDropTargetHeightForNotDragging(animated: true)
        }
    }

    private var viewDidAppearOnce = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if self.viewDidAppearOnce == false {
            self.viewDidAppearOnce = true
            self.instructionalView?.performInstructionalAnimation(completion: nil)
        }
    }

    @IBAction private func instructionalViewTapped(_ sender: Any) {
        self.instructionalView?.performInstructionalAnimation(completion: nil)
    }

    // MARK: UIDropInteractionDelegate

    // Data Updates

    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return !session.reminderDrags.isEmpty
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        guard !session.reminderDrags.isEmpty else { return UIDropProposal(operation: .forbidden) }
        return UIDropProposal(operation: .copy)
    }

    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        let identifiers = session.reminderDrags.map({ $0.reminder.uuid })
        self.delegate?.userDidPerformDrop(with: identifiers, onTargetZoneWithin: self)
    }

    // MARK: Handle View Layouts

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // if we change size (rotate or ipad resize) and the video is not at the beginning,
        // just start it playing to the beginning
        guard self.animationView?.hoverState != .noHover else { return }
        self.animationView?.hoverState = .noHover
    }

    // Because the child View controller layout subviews and other layout methods get called AFTER the parent
    // I need this childVC to cause the collectionView from the parent to get its insets updated
    // Or else, during rotation, the parent VC sees the wrong height for the dropTargetView
    // kind of hacky, but I couldn't figure out a better way to do it.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if self.isDragInProgress == false {
            self.updateDropTargetHeightForNotDragging(animated: false)
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewDidLayoutSubviews()

        if self.isDragInProgress == false {
            self.updateDropTargetHeightForNotDragging(animated: false)
        }
    }

    func updateDropTargetHeightAndPlayAnimationForDragging(animated: Bool,
                                                           completion: ((Bool) -> Void)? = nil)
    {
        let changes: () -> Void = {
            let height = self.view.bounds.height
            self.dropTargetViewHeightConstraint?.constant = height
            self.delegate?.animateAlongSideDropTargetViewResize(within: self)?()
        }

        guard animated == true else {
            changes()
            completion?(false)
            return
        }

        UIView.style_animateNormal({
            changes()
            self.view.layoutIfNeeded()
        }, completion: completion ?? { _ in })
    }

    func updatePlayAnimationForDrop() {
        guard self.animationView?.hoverState != .drop else { return }
        self.animationView?.hoverState = .drop
    }

    private func updateDropTargetHeightForNotDragging(animated: Bool) {
        let verticalSizeClassIsRegular = self.view.traitCollection.verticalSizeClassIsRegular
        let changes: () -> Void = {
            let height: CGFloat
            switch verticalSizeClassIsRegular {
            case false:
                height = self.view.bounds.height
            case true:
                height = self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
                    ? type(of: self).style_dropTargetViewCompactHeightAccessibilityTextSizeEnabled
                    : type(of: self).style_dropTargetViewCompactHeight
            }
            self.dropTargetViewHeightConstraint?.constant = height
            self.delegate?.animateAlongSideDropTargetViewResize(within: self)?()
        }

        guard animated == true else {
            changes()
            return
        }

        UIView.style_animateNormal {
            changes()
            self.view.layoutIfNeeded()
        }
    }

    // MARK: Handle Drag and Drop

    @objc private func applicationWillEnterForeground(_ notification: Any) {
        guard self.viewDidAppearOnce == true else { return }
        self.updateDropTargetHeightForNotDragging(animated: true)
        self.animationView?.hardReset()
        self.instructionalView?.performInstructionalAnimation(completion: nil)
    }

    var isDragInProgress = false {
        didSet {
            self.instructionalView?.isDragInProgress = self.isDragInProgress
        }
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnter session: UIDropSession) {
        self.isDragInProgress = true
        self.updateDropTargetHeightAndPlayAnimationForDragging(animated: true)
        self.delegate?.userDidStartDrag(with: session.reminderDrags, within: self)
        guard self.animationView?.hoverState != .drop else { return }
        self.animationView?.hoverState = .hover
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidExit session: UIDropSession) {
        self.isDragInProgress = false
        self.delegate?.userDidCancelDrag(within: self)
        guard self.animationView?.hoverState != .drop else { return }
        self.animationView?.hoverState = .noHover
    }

    func dropInteraction(_ interaction: UIDropInteraction, concludeDrop session: UIDropSession) {
        self.isDragInProgress = false
        self.updatePlayAnimationForDrop()
    }
}

extension UIDropSession {
    fileprivate var reminderDrags: [ReminderAndVesselValue] {
        return self.localDragSession?.items.compactMap({ $0.localObject as? ReminderAndVesselValue }) ?? []
    }
}

class OnlySubviewsTouchableView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let touchedView = super.hitTest(point, with: event)
        // if the deepest touchedview is myself, return NIL so it passes through
        guard touchedView !== self else { return nil }
        // otherwise just use the super value
        return touchedView
    }
}
