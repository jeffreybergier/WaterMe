//
//  ReminderIntervalPickerViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/24/17.
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

class ReminderIntervalPickerViewController: StandardViewController {

    typealias CompletionHandler = (UIViewController, Int?) -> Void

    class func newVC(from storyboard: UIStoryboard!,
                     existingValue: Int,
                     popoverSourceView: UIView?,
                     completionHandler: @escaping CompletionHandler) -> UIViewController
    {
        let id = "ReminderIntervalPickerViewController"
        // swiftlint:disable:next force_cast
        let navVC = storyboard.instantiateViewController(withIdentifier: id) as! UINavigationController
        // swiftlint:disable:next force_cast
        let vc = navVC.viewControllers.first as! ReminderIntervalPickerViewController
        vc.completionHandler = completionHandler
        vc.existingValue = existingValue
        if let sourceView = popoverSourceView {
            navVC.modalPresentationStyle = .popover
            navVC.popoverPresentationController?.sourceView = sourceView
            navVC.popoverPresentationController?.sourceRect = sourceView.bounds
            navVC.popoverPresentationController?.delegate = vc
        } else {
            navVC.presentationController?.delegate = vc
        }
        return navVC
    }

    @IBOutlet private weak var pickerView: UIPickerView?

    private var completionHandler: CompletionHandler!
    private var existingValue: Int = ReminderConstants.defaultInterval

    private let data: [Int] = (ReminderConstants.minimumInterval...ReminderConstants.maximumInterval).map({ $0 })
    private let formatter = DateComponentsFormatter.newReminderIntervalFormatter
    private var rowCache: [Int : NSAttributedString] = [:]
    private var heightCache: CGFloat?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = LocalizedString.title
        self.view.backgroundColor = Color.systemBackgroundColor

        let existingIndex = self.data.firstIndex(of: self.existingValue) ?? 0
        self.pickerView?.selectRow(existingIndex, inComponent: 0, animated: false)
    }

    @IBAction private func cancelButtonTapped(_ sender: Any) {
        self.completionHandler(self, nil)
    }

    @IBAction private func doneButtonTapped(_ sender: Any) {
        let selectedIndex = self.pickerView?.selectedRow(inComponent: 0) ?? 0
        let selectedItem = self.data[selectedIndex]
        self.completionHandler(self, selectedItem)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.rowCache = [:]
        self.heightCache = nil
        self.pickerView?.reloadAllComponents()
    }
}

extension ReminderIntervalPickerViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView,
                    viewForRow row: Int,
                    forComponent component: Int,
                    reusing view: UIView?) -> UIView
    {
        let view: UILabel = (view as? UILabel) ?? UILabel()
        view.attributedText = self.attributedString(forRow: row)
        view.sizeToFit()
        return view
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        if let cache = self.heightCache { return cache }
        let height = self.attributedString(forRow: 100).size().height + 8
        self.heightCache = height
        return height
    }

    private func attributedString(forRow row: Int) -> NSAttributedString {
        if let cache = self.rowCache[row] {
            return cache
        }
        let days = self.data[row]
        let interval: TimeInterval = TimeInterval(days) * (24 * 60 * 60)
        let formattedString = self.formatter.string(from: interval) ?? "–"
        let string = NSAttributedString(string: formattedString,
                                        attributes: Font.selectableTableViewCell.attributes)
        self.rowCache[row] = string
        return string
    }
}

extension ReminderIntervalPickerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.data.count
    }
}

extension ReminderIntervalPickerViewController: UIPopoverPresentationControllerDelegate /*: UIAdaptivePresentationControllerDelegate*/
{
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.doneButtonTapped(presentationController)
    }

    func presentationController(_ presentationController: UIPresentationController,
                                willPresentWithAdaptiveStyle style: UIModalPresentationStyle,
                                transitionCoordinator: UIViewControllerTransitionCoordinator?)
    {
        switch style {
        case .none:
            self.preferredContentSize = .init(width: 320, height: 260)
        case .overFullScreen, .formSheet:
            self.preferredContentSize = .zero
        default:
            assertionFailure("Unexpected presentation style reached")
        }
    }

    override func adaptivePresentationStyle(for controller: UIPresentationController,
                                            traitCollection: UITraitCollection) -> UIModalPresentationStyle
    {
        guard !traitCollection.preferredContentSizeCategory.isAccessibilityCategory else {
            return super.adaptivePresentationStyle(for: controller, traitCollection: traitCollection)
        }
        // if on narrow iphone screen, present as popover
        // on ipad present as normal form sheet
        return traitCollection.horizontalSizeClassIsCompact ? .none : .formSheet
    }
}
