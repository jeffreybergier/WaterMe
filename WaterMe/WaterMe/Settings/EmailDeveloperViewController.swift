//
//  EmailDeveloperViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/1/18.
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

import Calculate
import DatumL
import MessageUI
import UIKit
import MobileCoreServices

class EmailDeveloperViewController: MFMailComposeViewController, MFMailComposeViewControllerDelegate {

    typealias Completion = (UIViewController?) -> Void

    class func newVC(completion: Completion?) -> UIViewController {
        if self.canSendMail() == true {
            let vc = EmailDeveloperViewController()
            vc.mailComposeDelegate = vc
            vc.setSubject(LocalizedString.subject)
            vc.setToRecipients([PrivateKeys.kEmailAddress])
            vc.completion = completion
            vc.view.tintColor = Color.tint // hack because the MFMailComposeVC does not do this automatically for Cancel/Send buttons
            return vc
        } else {
            let vc = UIAlertController(copyEmailAlertWithAddress: PrivateKeys.kEmailAddressURL) {
                UIPasteboard.general.setValue(PrivateKeys.kEmailAddress, forPasteboardType: kUTTypeUTF8PlainText as String)
                completion?(nil)
            }
            return vc
        }
    }

    private var completion: Completion?

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?)
    {
        self.completion?(self)
    }
}

extension UIAlertController {
    convenience init(copyEmailAlertWithAddress address: URL, completion: (() -> Void)?) {
        self.init(title: LocalizedString.copyEmailAlertButtonTitle,
                  message: LocalizedString.copyEmailAlertMessage,
                  preferredStyle: .alert)
        let copy = UIAlertAction(title: LocalizedString.copyEmailAlertButtonTitle, style: .default) { _ in
            completion?()
        }
        let cancel = UIAlertAction(title: LocalizedString.buttonTitleDismiss, style: .cancel) { _ in
            completion?()
        }
        self.addAction(copy)
        self.addAction(cancel)
    }
}
