//
//  CoreDataMigratorViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 29/12/17.
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
import Calculate

class CoreDataMigratorViewController: StandardViewController, HasBasicController {

    enum UIState {
        case launch, migrating, success, error(MigratableError)
    }

    class func newVC(migrator: Migratable, basicRC: BasicController, completion: @escaping (UIViewController, Bool) -> Void) -> UIViewController {
        let sb = UIStoryboard(name: "CoreDataMigration", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let vc = sb.instantiateInitialViewController() as! ModalParentViewController
        vc.configureChild = { vc in
            // swiftlint:disable:next force_cast
            var vc = vc as! CoreDataMigratorViewController
            vc.completionHandler = completion
            vc.configure(with: basicRC)
            vc.migrator = migrator
        }
        return vc
    }

    @IBOutlet private weak var contentView: UIView?
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var subtitleLabel: UILabel?
    @IBOutlet private weak var bodyLabel: UILabel?
    @IBOutlet private weak var progressView: UIProgressView?
    @IBOutlet private weak var migrateButton: UIButton?
    @IBOutlet private weak var cancelButton: UIButton?
    @IBOutlet private weak var deleteButton: UIButton?
    @IBOutlet private weak var contactDeveloperButton: UIButton?

    private var completionHandler: ((UIViewController, Bool) -> Void)!
    private var migrator: Migratable!
    var basicRC: BasicController?
    private var state = UIState.launch {
        didSet {
            self.configureAttributedText()
            self.view.layoutIfNeeded()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.tintColor = Color.tint
        self.progressView?.progress = 0
        self.configureAttributedText()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.log(viewOperation: .coreDataMigration)
    }

    // swiftlint:disable:next function_body_length
    private func configureAttributedText() {
        // set things to all defaults
        self.titleLabel?.attributedText = NSAttributedString(string: UIApplication.LocalizedString.appTitle,
                                                             font: .migratorTitle)
        self.subtitleLabel?.attributedText = NSAttributedString(string: LocalizedString.subtitle,
                                                                font: .migratorSubtitle)
        self.bodyLabel?.attributedText = NSAttributedString(string: LocalizedString.body,
                                                            font: .migratorBody)
        self.migrateButton?.setAttributedTitle(NSAttributedString(string: LocalizedString.migrateButtonTitle,
                                                                  font: .migratorPrimaryButton),
                                                                  for: .normal)
        self.migrateButton?.setAttributedTitle(NSAttributedString(string: LocalizedString.migratingButtonTitle,
                                                                  font: .migratorPrimaryButton),
                                                                  for: .disabled)
        self.cancelButton?.setAttributedTitle(NSAttributedString(string: LocalizedString.cancelButtonTitle,
                                                                 font: .migratorSecondaryButton),
                                                                 for: .normal)
        self.deleteButton?.setAttributedTitle(NSAttributedString(string: LocalizedString.deleteButtonTitle,
                                                                 font: .migratorSecondaryButton),
                                                                 for: .normal)
        self.contactDeveloperButton?.setAttributedTitle(
            NSAttributedString(string: SettingsMainViewController.LocalizedString.cellTitleEmailDeveloper,
                               font: .migratorSecondaryButton),
                               for: .normal
        )
        
        self.progressView?.isHidden = false
        self.bodyLabel?.isHidden = false
        self.migrateButton?.alpha = 0 // setting alpha to 0 improves animations
        self.cancelButton?.alpha = 0
        self.deleteButton?.alpha = 0
        self.contactDeveloperButton?.alpha = 0
        self.migrateButton?.isHidden = false
        self.cancelButton?.isHidden = false
        self.deleteButton?.isHidden = false
        // TODO: Fix this layout issue
        // self.contactDeveloperButton?.isHidden = true
        self.migrateButton?.isEnabled = true
        self.cancelButton?.isEnabled = true
        self.deleteButton?.isEnabled = true
        // TODO: Fix issue where button is grayed out
        // self.contactDeveloperButton?.isEnabled = false

        // customize things for each state
        let disableAlpha: CGFloat = 0.3
        switch self.state {
        case .launch:
            self.progressView?.isHidden = true
            self.migrateButton?.alpha = 1
            self.cancelButton?.alpha = 1
            self.deleteButton?.alpha = 1
        case .migrating:
            self.migrateButton?.alpha = disableAlpha
            self.cancelButton?.isHidden = true
            self.deleteButton?.isHidden = true
            self.migrateButton?.isEnabled = false
            self.bodyLabel?.attributedText = NSAttributedString(string: LocalizedString.bodyMigrating,
                                                                font: .migratorBodySmall)
            self.subtitleLabel?.attributedText = NSAttributedString(string: LocalizedString.migratingButtonTitle,
                                                                    font: .migratorSubtitle)
        case .success:
            self.progressView?.isHidden = true
            self.migrateButton?.isHidden = true
            self.deleteButton?.isHidden = true
            self.cancelButton?.alpha = 1
            self.bodyLabel?.attributedText = NSAttributedString(string: LocalizedString.bodySuccess,
                                                                font: .migratorBody)
            self.cancelButton?.setAttributedTitle(
                NSAttributedString(string: LocalizedString.finishButtonTitle,
                                   font: .migratorPrimaryButton),
                                   for: .normal
            )
        case .error(let error):
            self.cancelButton?.alpha = 1
            self.contactDeveloperButton?.alpha = 1
            self.migrateButton?.isHidden = true
            self.deleteButton?.isHidden = true
            self.contactDeveloperButton?.isHidden = false
            self.contactDeveloperButton?.isEnabled = true
            let message: String
            switch error {
            case .startError:
                message = LocalizedString.bodyFailure1
            case .finishError:
                message = LocalizedString.bodyFailure2
            case .migrateError:
                message = LocalizedString.bodyFailure3
            }
            self.bodyLabel?.attributedText = NSAttributedString(string: message, font: .migratorBody)
            self.subtitleLabel?.attributedText = NSAttributedString(string: LocalizedString.subtitleFailure,
                                                                    font: .migratorSubtitle)
            self.cancelButton?.setAttributedTitle(
                NSAttributedString(string: UIAlertController.LocalizedString.buttonTitleDismiss,
                                   font: .migratorPrimaryButton),
                                   for: .normal
            )
        }
    }

    @IBAction private func migrateButtonTapped(_ sender: Any) {
        guard let basicRC = self.basicRC else {
            let message = "RealmController missing on a VC where this should not be possible."
            message.log()
            assertionFailure(message)
            UIView.style_animateNormal() {
                self.state = .error(.startError)
                self.view.layoutIfNeeded()
            }
            return
        }
        // this VC could disappear while the migration is in progress
        // AND the VC does not own the migrator.
        // So it IS valid for the VC to be NIL while the migrator is working
        // So this weak self is required
        UIView.style_animateNormal({
            self.state = .migrating
            self.view.layoutIfNeeded()
        }, completion: { _ in
            UIApplication.shared.isIdleTimerDisabled = true
            self.progressView?.observedProgress = self.migrator.start(destination: basicRC)
            { [weak self] result in
                UIApplication.shared.isIdleTimerDisabled = false
                guard let welf = self else { return }
                UIView.style_animateNormal() {
                    switch result {
                    case .success:
                        welf.state = .success
                    case .failure(let error):
                        welf.state = .error(error)
                    }
                    self?.view.layoutIfNeeded()
                }
            }
        })
    }

    @IBAction private func cancelButtonTapped(_ sender: Any) {
        Analytics.log(event: Analytics.CoreDataMigration.migrationSkipped)
        self.completionHandler(self, false)
    }

    @IBAction private func deleteButtonTapped(_ sender: Any) {
        let vc = UIAlertController(title: nil,
                                   message: LocalizedString.bodyDeleteConfirmation,
                                   preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: LocalizedString.deleteButtonTitle,
                                         style: .destructive)
        { _ in
            Analytics.log(event: Analytics.CoreDataMigration.migrationDeleted)
            let result = self.migrator.skipMigration()
            switch result {
            case .success:
                self.completionHandler(self, false)
            case .failure(let error):
                UIView.style_animateNormal() {
                    self.state = .error(error)
                    self.view.layoutIfNeeded()
                }
            }
        }
        let cancelAction = UIAlertAction(title: UIAlertController.LocalizedString.buttonTitleCancel,
                                         style: .cancel,
                                         handler: nil)
        vc.addAction(deleteAction)
        vc.addAction(cancelAction)
        vc.popoverPresentationController?.sourceView = (sender as? UIView) ?? self.view
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction private func contactDeveloperButtonTapped(_ sender: Any) {
        Analytics.log(viewOperation: .emailDeveloper)
        let vc = EmailDeveloperViewController.newVC() { vc in
            guard let vc = vc else { return }
            vc.dismissNoForReal()
        }
        self.present(vc, animated: true, completion: nil)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.configureAttributedText()
    }

}
