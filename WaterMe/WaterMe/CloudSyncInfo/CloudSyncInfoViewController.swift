//
//  PurchaseThanksViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 14/1/18.
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

import Cheers
import Store
import UIKit

typealias CloudSyncInfoViewControllerCompletion = (UIViewController) -> Void

class CloudSyncInfoViewController: StandardViewController {

    class func newVC(completion: @escaping CloudSyncInfoViewControllerCompletion) -> UIViewController {
        let sb = UIStoryboard(name: "CloudSyncInfo", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let vc = sb.instantiateInitialViewController() as! ModalParentViewController
        vc.configureChild = { vc in
            // swiftlint:disable:next force_cast
            let vc = vc as! CloudSyncInfoViewController
            vc.completionHandler = completion
        }
        return vc
    }

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var bodyLabel: UILabel?
    @IBOutlet private weak var settingsButton: UIButton?
    @IBOutlet private weak var dismissButton: UIButton?

    private var completionHandler: CloudSyncInfoViewControllerCompletion!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentView.style_setCornerRadius()
        self.configureAttributedText()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.log(viewOperation: .cloudSyncInfo)
    }

    private func configureAttributedText() {
        self.titleLabel?.attributedText = NSAttributedString(string: LocalizedString.title, font: .migratorTitle)
        self.bodyLabel?.attributedText = NSAttributedString(string: LocalizedString.body, font: .migratorBody)
        self.dismissButton?.setAttributedTitle(NSAttributedString(string: UIAlertController.LocalizedString.buttonTitleDismiss, font: .migratorPrimaryButton), for: .normal)
        self.settingsButton?.setAttributedTitle(NSAttributedString(string: SettingsMainViewController.LocalizedString.cellTitleOpenSettings, font: .migratorSecondaryButton), for: .normal)
    }

    @IBAction private func settingsButtonTapped(_ sender: Any) {
        UIApplication.shared.openAppSettings(completion: { _ in self.completionHandler(self) })
    }

    @IBAction private func dismissButtonTapped(_ sender: Any) {
        self.completionHandler(self)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.configureAttributedText()
    }
}
