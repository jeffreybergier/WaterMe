//
//  TextFieldTableViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/2/17.
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

class TextFieldTableViewCell: UITableViewCell {

    static let reuseID = "TextFieldTableViewCell"
    class var nib: UINib { return UINib(nibName: self.reuseID, bundle: Bundle(for: self.self)) }

    @IBOutlet private weak var textField: UITextField?
    @IBOutlet private weak var label: UILabel?
    @IBOutlet private weak var topConstraint: NSLayoutConstraint?
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint?
    @IBOutlet private weak var leadingConstraint: NSLayoutConstraint?
    @IBOutlet private weak var trailingConstraint: NSLayoutConstraint?

    var textChanged: ((String) -> Void)?

    func setTextField(text: String?) {
        self.textField?.attributedText = NSAttributedString(string: text ?? "", font: .textInputTableViewCell)
    }

    func setLabelText(_ labelText: String?, andTextFieldPlaceHolderText placeHolderText: String) {
        self.textField?.attributedPlaceholder = NSAttributedString(string: placeHolderText, font: .readOnlyTableViewCell)
        if let labelText = labelText {
            self.label?.isHidden = false
            self.label?.attributedText = NSAttributedString(string: labelText, font: .readOnlyTableViewCell)
        } else {
            self.label?.isHidden = true
            self.label?.attributedText = NSAttributedString(string: "", font: .readOnlyTableViewCell)
        }
    }

    func textFieldBecomeFirstResponder() {
        self.textField?.becomeFirstResponder()
    }

    @IBAction private func textChanged(_ sender: Any) {
        let newValue = self.textField?.text ?? ""
        self.textChanged?(newValue)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.textField?.delegate = self
        self.topConstraint?.constant = UITableViewCell.style_textFieldCellTopPadding
        self.bottomConstraint?.constant = UITableViewCell.style_textFieldCellBottomPadding
        self.leadingConstraint?.constant = UITableViewCell.style_textFieldCellLeadingPadding
        self.trailingConstraint?.constant = UITableViewCell.style_textFieldCellTrailingPadding
        self.prepareForReuse()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.textField?.attributedText = nil
        self.textField?.attributedPlaceholder = nil
        self.label?.attributedText = nil
        self.textChanged = nil
        self.label?.isHighlighted = true
    }
}

extension TextFieldTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
