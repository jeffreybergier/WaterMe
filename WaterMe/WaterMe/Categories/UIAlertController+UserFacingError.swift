//
//  UIAlertController+UserFacingError.swift
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

import Calculate
import Datum
import UIKit

extension UIAlertController {
    
    typealias UserSelection = (RecoveryAction) -> Void
    
    class func presentAlertVC(for error: UserFacingError,
                              over presentingVC: UIViewController,
                              from barButtonItem: UIBarButtonItem? = nil,
                              completionHandler completion: UserSelection? = nil)
    {
        let recoveryActions = error.recoveryActions.map()
        { recoveryOption -> UIAlertAction in
            let action = UIAlertAction(title: recoveryOption.title,
                                       style: recoveryOption.actionStyle)
            { _ in
                recoveryOption.automaticExecution?()
                completion?(recoveryOption)
            }
            return action
        }
        let actionSheet: UIAlertController
        if let bbi = barButtonItem {
            actionSheet = .init(title: error.title,
                                message: error.message,
                                preferredStyle: .actionSheet)
            actionSheet.popoverPresentationController?.barButtonItem = bbi
        } else {
            actionSheet = .init(title: error.title,
                                message: error.message,
                                preferredStyle: .alert)
        }
        recoveryActions.forEach(actionSheet.addAction)
        presentingVC.present(actionSheet, animated: true, completion: nil)
    }
}

extension UIAlertController {

    enum ReminderDeleteConfirmationResult {
        case delete, pause, cancel
    }
    
    struct ReminderDeleteConfirmationOptions: OptionSet {
        let rawValue: Int
        static let pause = ReminderDeleteConfirmationOptions(rawValue: 1 << 0)
    }
    
    convenience init(error: UserFacingError,
                     sender: PopoverSender?,
                     selectionHandler: ((RecoveryAction?) -> Void)? = nil)
    {
        self.init(title: error.title, message: error.message, preferredStyle: sender == nil ? .alert : .actionSheet)
        error.recoveryActions.forEach { option in
            let action = UIAlertAction(title: option.title,
                                       style: option.actionStyle)
            { _ in
                option.automaticExecution?()
                selectionHandler?(option)
            }
            self.addAction(action)
        }
        let dismiss = UIAlertAction(title: LocalizedString.buttonTitleDismiss,
                                    style: .cancel,
                                    handler: { _ in selectionHandler?(nil) })
        self.addAction(dismiss)
        guard let sender = sender else { return }
        switch sender {
        case .right(let bbi):
            self.popoverPresentationController?.barButtonItem = bbi
        case .left(let (view, location)):
            self.popoverPresentationController?.sourceView = view
            self.popoverPresentationController?.sourceRect = view.bounds.rect(with: location)
            self.popoverPresentationController?.permittedArrowDirections = [.up, .down]
        }
    }

    convenience init(localizedDeleteConfirmationWithOptions options: ReminderDeleteConfirmationOptions,
                     sender: PopoverSender?,
                     userConfirmationHandler confirmed: ((ReminderDeleteConfirmationResult) -> Void)?)
    {
        let style: UIAlertController.Style = sender != nil ? .actionSheet : .alert
        self.init(title: nil, message: LocalizedString.deleteAlertMessage, preferredStyle: style)
        let delete = UIAlertAction(title: LocalizedString.buttonTitleDelete, style: .destructive) { _ in
            confirmed?(.delete)
        }
        let dont = UIAlertAction(title: LocalizedString.buttonTitleDontDelete, style: .cancel) { _ in
            confirmed?(.cancel)
        }
        self.addAction(delete)
        self.addAction(dont)
        if options.contains(.pause) {
            let pause = UIAlertAction(title: LocalizedString.buttonTitlePause, style: .default) { _ in
                confirmed?(.pause)
            }
            self.addAction(pause)
        }
        guard let sender = sender else { return }
        switch sender {
        case .right(let bbi):
            self.popoverPresentationController?.barButtonItem = bbi
        case .left(let (view, location)):
            self.popoverPresentationController?.sourceView = view
            self.popoverPresentationController?.sourceRect = view.bounds.rect(with: location)
            self.popoverPresentationController?.permittedArrowDirections = [.up, .down]
        }
    }
}

extension UIAlertController {
    convenience init(localizedSiriShortcutsUnavailableAlertWithCompletionHandler completion: (() -> Void)?) {
        self.init(title: UserActivityConfigurator.LocalizedString.siriShortcutsUnavailableTitle,
                  message: UserActivityConfigurator.LocalizedString.siriShortcutsUnavailableMessage,
                  preferredStyle: .alert)
        let dismiss = UIAlertAction(title: LocalizedString.buttonTitleDismiss,
                                    style: .cancel)
        { _ in
            completion?()
        }
        self.addAction(dismiss)
    }
}

extension UIAlertController {
    class func newLocalizedDarkModeImproperlyConfigured() -> UIAlertController? {
        if #available(iOS 13.0, *) { return nil } else {
            let ud = UserDefaults.standard
            guard ud.darkMode != .system else { return nil }
            let alertVC = UIAlertController(title: LocalizedString.darkModeImproperTitle,
                                            message: LocalizedString.darkModeImproperMessage,
                                            preferredStyle: .alert)
            let dismiss = UIAlertAction(title: LocalizedString.buttonTitleDismiss, style: .cancel) { _ in
                ud.darkMode = .system
            }
            alertVC.addAction(dismiss)
            return alertVC
        }
    }
}
