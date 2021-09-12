//
//  SettingsMainPurchaseDimmingViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 14/1/18.
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

import UIKit

class SettingsMainPurchaseDimmingViewController: SettingsMainViewController {

    private var purchaseInProgress: (() -> Void)? {
        didSet {
            UIView.style_animateNormal {
                if self.purchaseInProgress != nil {
                    self.tableViewController?.tableView?.isUserInteractionEnabled = false
                    self.purchaseActivityIndicator.startAnimating()
                } else {
                    self.tableViewController?.tableView?.isUserInteractionEnabled = true
                    self.purchaseActivityIndicator.stopAnimating()
                }
            }
        }
    }

    private let purchaseActivityIndicator = TintColorActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.purchaseActivityIndicator)

        let pc = AppDelegate.shared.purchaseController
        self.tableViewController?.tipJarRowChosen = { chosen, deselectRowAnimated in
            switch chosen {
            case .free:
                UIApplication.shared.openWriteReviewPage(completion: { _ in deselectRowAnimated?(true) })
            case .small(let product), .medium(let product), .large(let product):
                self.purchaseInProgress = {
                    deselectRowAnimated?(true)
                }
                pc?.buy(product: product)
            }
        }
        pc?.fetchTipJarProducts() { [weak self] products in
            guard let products = products else { Analytics.log(event: Analytics.IAPOperation.loadError); return; }
            self?.tableViewController?.products = products
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        AppDelegate.shared.purchaseController?.transactionsInFlightUpdated = { [weak self] in
            self?.checkForPurchasesInFlight()
        }
        self.checkForPurchasesInFlight()
    }

    private func checkForPurchasesInFlight() {
        guard self.presentedViewController == nil else { return }
        let pc = AppDelegate.shared.purchaseController
        guard let transaction = pc?.nextTransactionForPresentingToUser() else { return }
        self.purchaseInProgress?()
        self.purchaseInProgress = nil
        let _vc = PurchaseThanksViewController.newVC(for: transaction) { vc in
            guard let vc = vc else { self.checkForPurchasesInFlight(); return; }
            vc.dismissNoForReal(completion: { self.checkForPurchasesInFlight() })
        }
        guard let vc = _vc else { return }
        self.present(vc, animated: true, completion: nil)
    }

    @IBAction override func doneButtonTapped(_ sender: Any) {
        AppDelegate.shared.purchaseController?.transactionsInFlightUpdated = nil
        super.doneButtonTapped(sender)
    }

}

class TintColorActivityIndicatorView: UIActivityIndicatorView {
    override func tintColorDidChange() {
        super.tintColorDidChange()
        self.color = self.tintColor
    }
}
