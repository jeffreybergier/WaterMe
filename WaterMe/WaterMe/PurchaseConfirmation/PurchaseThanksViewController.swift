//
//  PurchaseThanksViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 14/1/18.
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

import Cheers
import Store
import UIKit

typealias PurchaseThanksCompletion = (UIViewController?) -> Void

class PurchaseThanksViewController: StandardViewController {

    class func newVC(for inFlight: InFlightTransaction, completion: @escaping PurchaseThanksCompletion) -> UIViewController? {
        let alert: UIAlertController
        switch inFlight.state {
        case .cancelled:
            return nil
        case .success:
            Analytics.log(event: Analytics.IAPOperation.buySuccess)
            return PurchaseThanksViewController.newVC { vc in
                "💵 Purchase Complete: \(inFlight.transaction.payment.productIdentifier)".log(as: .warning)
                AppDelegate.shared.purchaseController?.finish(inFlight: inFlight)
                completion(vc)
            }
        case .errorNetwork:
            Analytics.log(event: Analytics.IAPOperation.buyErrorNetwork)
            alert = UIAlertController(
                title: LocalizedString.errorAlertTitle,
                message: LocalizedString.errorNetworkAlertMessage,
                preferredStyle: .alert
            )
        case .errorNotAllowed:
            Analytics.log(event: Analytics.IAPOperation.buyErrorNotAllowed)
            alert = UIAlertController(
                title: LocalizedString.errorAlertTitle,
                message: LocalizedString.errorNotAllowedAlertMessage,
                preferredStyle: .alert
            )
        case .errorUnknown:
            Analytics.log(event: Analytics.IAPOperation.buyErrorUnknown)
            alert = UIAlertController(
                title: LocalizedString.errorAlertTitle,
                message: LocalizedString.errorUnknownAlertMessage,
                preferredStyle: .alert
            )
        }
        let confirm = UIAlertAction(title: UIAlertController.LocalizedString.buttonTitleDismiss,
                                    style: .cancel)
        { _ in
            AppDelegate.shared.purchaseController?.finish(inFlight: inFlight)
            completion(nil)
        }
        Analytics.log(viewOperation: .errorAlertPurchase)
        alert.addAction(confirm)
        return alert
    }

    private class func newVC(completion: @escaping PurchaseThanksCompletion) -> UIViewController {
        let sb = UIStoryboard(name: "PurchaseThanks", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let vc = sb.instantiateInitialViewController() as! ModalParentViewController
        vc.configureChild = { vc in
            // swiftlint:disable:next force_cast
            let vc = vc as! PurchaseThanksViewController
            vc.completionHandler = completion
        }
        return vc
    }

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var subtitleLabel: UILabel?
    @IBOutlet private weak var bodyLabel: UILabel?
    @IBOutlet private weak var reviewButton: UIButton?
    @IBOutlet private weak var cancelButton: UIButton?

    private var completionHandler: PurchaseThanksCompletion!
    private let cheerView: CheerView = {
        let v = CheerView()
        v.config.colors = [Color.confetti1, Color.confetti2]
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentView.style_setCornerRadius()
        self.contentView.addSubview(self.cheerView)
        self.contentView.addConstraints([
            self.contentView.leadingAnchor.constraint(equalTo: self.cheerView.leadingAnchor, constant: 0),
            self.contentView.trailingAnchor.constraint(equalTo: self.cheerView.trailingAnchor, constant: 0),
            self.cheerView.heightAnchor.constraint(equalToConstant: 1),
            ])
        self.configureAttributedText()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.animateAlongSideTransitionCoordinator(animations: nil, completion: {
            self.cheerView.start()
            Timer.scheduledTimer(withTimeInterval: 7, repeats: false) { _ in
                self.cheerView.stop()
            }
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Analytics.log(viewOperation: .purchaseThanks)
    }

    private func configureAttributedText() {
        self.titleLabel?.attributedText = NSAttributedString(string: LocalizedString.title, font: .migratorTitle)
        self.subtitleLabel?.attributedText = NSAttributedString(string: LocalizedString.subtitle, font: .migratorSubtitle)
        self.bodyLabel?.attributedText = NSAttributedString(string: LocalizedString.body, font: .migratorBody)
        self.reviewButton?.setAttributedTitle(NSAttributedString(string: SettingsMainViewController.LocalizedString.cellTitleTipJarFree, font: .migratorPrimaryButton), for: .normal)
        self.cancelButton?.setAttributedTitle(NSAttributedString(string: UIAlertController.LocalizedString.buttonTitleDismiss, font: .migratorSecondaryButton), for: .normal)
    }

    @IBAction private func reviewButtonTapped(_ sender: Any) {
        UIApplication.shared.openWriteReviewPage(completion: { _ in self.completionHandler(self) })
    }

    @IBAction private func cancelButtonTapped(_ sender: Any) {
        self.completionHandler(self)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.configureAttributedText()
    }
}
