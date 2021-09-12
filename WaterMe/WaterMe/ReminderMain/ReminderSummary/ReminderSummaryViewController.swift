//
//  ReminderSummaryViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/4/18.
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

import UIKit
import SimpleImageViewer
import Datum

class ReminderSummaryViewController: StandardViewController {

    typealias Completion = (Action, Identifier, UIViewController) -> Void
    enum Action {
        case cancel, performReminder, editReminderVessel, editReminder
    }

    // swiftlint:disable:next function_parameter_count
    class func newVC(reminderID: Identifier,
                     basicController: BasicController,
                     hapticGenerator: UIFeedbackGenerator,
                     sourceView: UIView,
                     userActivityContinuation: NSUserActivityContinuedHandler?,
                     completion: @escaping Completion) -> UIViewController
    {
        let sb = UIStoryboard(name: "ReminderSummary", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let vc = sb.instantiateInitialViewController() as! ReminderSummaryViewController
        // configure presentation
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.delegate = vc
        vc.popoverPresentationController?.popoverBackgroundViewClass = ReminderSummaryPopoverBackgroundView.self
        vc.popoverPresentationController?.sourceView = sourceView
        vc.popoverPresentationController?.sourceRect = sourceView.bounds.rect(with: .center)
        vc.presentationController?.delegate = vc
        // configure needed properties
        vc.completion = completion
        vc.userActivityContinuation = userActivityContinuation
        vc.reminderResult = basicController.reminder(matching: reminderID)
        vc.reminderID = reminderID
        vc.haptic = hapticGenerator
        vc.userActivity = NSUserActivity(kind: .viewReminder,
                                         delegate: vc.userActivityDelegate)
        return vc
    }

    @IBOutlet private weak var darkBackgroundView: UIView?
    @IBOutlet var tableViewControllerLeadingTrailingConstraints: [NSLayoutConstraint]?
    @IBOutlet var tableViewMaximumWidthConstraint: NSLayoutConstraint!
    
    private(set) var isPresentedAsPopover = false

    var reminderResult: Result<Reminder, DatumError>!
    private var completion: Completion!
    private var userActivityContinuation: NSUserActivityContinuedHandler?
    private var reminderID: Identifier!
    private weak var tableViewController: ReminderSummaryTableViewController!
    private weak var haptic: UIFeedbackGenerator?
    //swiftlint:disable:next weak_delegate
    private let userActivityDelegate: UserActivityConfiguratorProtocol = UserActivityConfigurator()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.notificationToken = self.reminderResult?.value?.observe({ [weak self] in self?.reminderChanged($0) })
        self.updateViewForPresentation()
        self.userActivityDelegate.currentReminderAndVessel = { [weak self] in
            // should be unowned because this object should not exist longer
            // than the view controller. But since NIL is a possible return value
            // it just seems safer to go with weak
            return ReminderAndVesselValue(reminder: self?.reminderResult?.value)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.userActivityContinuation?([self])
        self.userActivityContinuation = nil
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.updateViewForPresentation()
        }, completion: nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateViewForPresentation()
    }

    private func updateViewForPresentation() {
        let tc = self.traitCollection
        let isDarkMode = !tc.userInterfaceStyleIsNormal

        var tableViewControllerInsets: CGFloat {
            self.isPresentedAsPopover
                ? 0
                : type(of: self).style_leadingTrailingPadding
        }

        var darkBackgroundViewAlpha: CGFloat {
            switch (self.isPresentedAsPopover, isDarkMode) {
            case (true, _): return 0
            case (false, true): return 0.8
            case (false, false): return 0.4
            }
        }

        self.tableViewMaximumWidthConstraint.isActive = !tc.preferredContentSizeCategory.isAccessibilityCategory
        self.darkBackgroundView?.alpha = darkBackgroundViewAlpha
        self.tableViewControllerLeadingTrailingConstraints?.forEach() { c in
            c.constant = tableViewControllerInsets
        }
    }

    private func reminderChanged(_ change: ReminderChange) {
        switch change {
        case .change:
            guard let reminder = self.reminderResult.value else { fallthrough }
            self.reminderID = Identifier(rawValue: reminder.uuid)
            self.tableViewController.tableView.reloadData()
        case .deleted, .error:
            self.completion(.cancel, self.reminderID, self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ReminderSummaryTableViewController {
            self.tableViewController = dest
            dest.delegate = self
        }
    }

    private var notificationToken: ObservationToken?
    deinit {
        self.notificationToken?.invalidate()
    }
}

extension ReminderSummaryViewController: ReminderSummaryTableViewControllerDelegate {

    internal func userChose(toViewImage image: UIImage,
                            rowDeselectionHandler: @escaping () -> Void,
                            within: ReminderSummaryTableViewController)
    {
        let config = DismissHandlingImageViewerConfiguration(image: image, completion:  { vc in
            vc.dismissNoForReal(completion: { rowDeselectionHandler() })
        })
        let vc = DismissHandlingImageViewerController(configuration: config)
        self.present(vc, animated: true, completion: nil)
    }

    internal func userChose(action: ReminderSummaryViewController.Action,
                            within: ReminderSummaryTableViewController)
    {
        if case .performReminder = action {
            self.configurePerformRemindersActivity()
            self.haptic?.prepare()
        }
        self.completion(action, self.reminderID, self)
    }

    private func configurePerformRemindersActivity() {
        let activity = NSUserActivity(kind: .performReminder,
                                      delegate: self.userActivityDelegate)
        self.userActivity = activity
        activity.needsSave = true
        activity.becomeCurrent()
    }
}

extension ReminderSummaryViewController: UIPopoverPresentationControllerDelegate {

    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        self.completion(.cancel, self.reminderID, self)
        return false
    }
}

extension ReminderSummaryViewController /*: UIAdaptivePresentationControllerDelegate*/ {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.completion(.cancel, self.reminderID, self)
    }

    func presentationController(_ presentationController: UIPresentationController,
                                willPresentWithAdaptiveStyle style: UIModalPresentationStyle,
                                transitionCoordinator: UIViewControllerTransitionCoordinator?)
    {
        // figure out if we're a popover or not
        switch style {
        case .none:
            self.isPresentedAsPopover = true
        case .overFullScreen:
            self.isPresentedAsPopover = false
        default:
            assertionFailure("Encountered unexpected presentation style.")
        }
        // remove the shadow from the popover via the popover presentation controller
        presentationController.removeShadow(in: transitionCoordinator)
        // have our view controller update based on our new presentation
        self.updateViewForPresentation()
    }
    
    override func adaptivePresentationStyle(for controller: UIPresentationController,
                                            traitCollection tc: UITraitCollection) -> UIModalPresentationStyle
    {
        let fullScreen = UIModalPresentationStyle.overFullScreen
        let popover = UIModalPresentationStyle.none

        // if we're in accessibility sizing, always run in full screen
        guard !tc.preferredContentSizeCategory.isAccessibilityCategory
            else { return fullScreen }
        switch tc.horizontalSizeClassIsCompact {
            // if the horizontal size class is compact, always run fullscreen
        case true: return fullScreen
            // if the horizontal size class is regular, then we need to check vertical
            // if vertical is regular, run as popover, if compact, run as fullscreen
            // iPhone 6+, 7+, 8+ run in this configuration when horizontal
        case false: return tc.verticalSizeClassIsRegular ? popover : fullScreen
        }
    }
}

extension UIPresentationController {
    fileprivate func removeShadow(in transitionCoordinator: UIViewControllerTransitionCoordinator?) {
        let _subterfuge = [
            "_",
            "sha",
            "dow",
            "Vi",
            "ew"
        ]
        let subterfuge = _subterfuge.reduce("", +)
        guard
            let self = self as? UIPopoverPresentationController,
            let tc = transitionCoordinator,
            self.sanityCheck(forKey: subterfuge) == true,
            let shadowView = self.value(forKey: subterfuge) as? UIImageView
        else { return }
        tc.animate(alongsideTransition: { _ in shadowView.alpha = 0 },
                   completion: { _ in shadowView.image = nil })
    }
}
