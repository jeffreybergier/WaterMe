//
//  ReminderSummaryTableViewCells+Models.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/15/18.
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

import Datum

extension ButtonTableViewCell {
    func configure(for action: ReminderSummaryTableViewController.ActionRows) {
        self.hairlineView?.backgroundColor = ReminderSummaryViewController.style_actionButtonSeparatorColor
        switch action {
        case .editReminder:
            self.locationInGroup = .middle
            self.label?.attributedText =
                NSAttributedString(string: UIApplication.LocalizedString.editReminder,
                                   font: .reminderSummaryActionButton)
        case .editReminderVessel:
            self.locationInGroup = .bottom
            self.label?.attributedText =
                NSAttributedString(string: UIApplication.LocalizedString.editVessel,
                                   font: .reminderSummaryActionButton)
        case .performReminder:
            self.locationInGroup = .top
            self.label?.attributedText =
                NSAttributedString(string: ReminderMainViewController.LocalizedString.buttonTitleReminderPerform,
                                   font: .reminderSummaryActionButton)
        }
    }
    
    func configureAsCancelButton() {
        self.label?.attributedText =
            NSAttributedString(string: UIAlertController.LocalizedString.buttonTitleCancel,
                               font: .reminderSummaryCancelButton)
        self.locationInGroup = .alone
    }
}

extension InfoTableViewCell {
    func configure(withNoteString noteString: String?) {
        self.locationInGroup = .alone
        self.label0?.attributedText =
            NSAttributedString(string: noteString ?? "",
                               font: .textInputTableViewCell)
        self.sublabel0?.attributedText =
            NSAttributedString(string: ReminderEditViewController.LocalizedString.sectionTitleNotes,
                               font: .reminderSummarySublabel)
    }
    
    func configureUnimportant(with reminder: Reminder?) {
        _ = {
            let vesselName = reminder?.vessel?.displayName
            let vesselNameStyle = vesselName != nil ?
                Font.reminderSummaryPrimaryLabel :
                Font.reminderSummaryPrimaryLabelValueNIL
            self.label0?.attributedText = NSAttributedString(string: vesselName ?? LocalizedString.ReminderVessel.untitledPlant,
                                                                      font: vesselNameStyle)
            self.sublabel0?.attributedText = NSAttributedString(string: ReminderSummaryViewController.LocalizedString.subheadPlantName,
                                                                         font: .reminderSummarySublabel)
        }()
        _ = {
            let lastPerformedDate = reminder?.lastPerformDate
            let dateString = self.timeAgoDateFormatter.timeAgoString(for: lastPerformedDate)
            self.label1?.attributedText = NSAttributedString(string: dateString,
                                                             font: .reminderSummaryPrimaryLabel)
            self.sublabel1?.attributedText = NSAttributedString(string: ReminderEditViewController.LocalizedString.sectionTitleLastPerformed,
                                                                font: .reminderSummarySublabel)
        }()
        _ = {
            guard let interval = reminder?.interval else { return }
            let intervalString = self.intervalFormatter.string(forDayInterval: interval)
            self.label2?.attributedText = NSAttributedString(string: intervalString,
                                                             font: .reminderSummaryPrimaryLabel)
            self.sublabel2?.attributedText = NSAttributedString(string: ReminderEditViewController.LocalizedString.sectionTitleInterval,
                                                                font: .reminderSummarySublabel)
        }()
    }

    func configureImportant(with reminder: Reminder?) {
        _ = {
            guard let reminderName = reminder?.kind.localizedLongString else { return }
            self.label0?.attributedText = NSAttributedString(string: reminderName,
                                                             font: .reminderSummaryPrimaryLabel)
            self.sublabel0?.attributedText = NSAttributedString(string: ReminderSummaryViewController.LocalizedString.subheadReminderKind,
                                                                font: .reminderSummarySublabel)
        }()
        if let kind = reminder?.kind, case .move(let _location) = kind, let location = _location {
            self.label1?.attributedText = NSAttributedString(string: location,
                                                             font: .reminderSummaryPrimaryLabel)
            self.sublabel1?.attributedText = NSAttributedString(string: ReminderSummaryViewController.LocalizedString.subheadMoveTo,
                                                                font: .reminderSummarySublabel)
        } else {
            self.stackView1?.isHidden = true
        }
        _ = {
            self.sublabel2?.attributedText = NSAttributedString(string: ReminderSummaryViewController.LocalizedString.subheadNextPerformDate,
                                                                font: .reminderSummarySublabel)
            if reminder?.isEnabled ?? true {
                let nextPerformDate = reminder?.nextPerformDate ?? Date()
                let dueDateString = self.dueDateFormatter.string(from: nextPerformDate)
                self.label2?.attributedText = NSAttributedString(string: dueDateString,
                                                                 font: .reminderSummaryPrimaryLabel)
            } else {
                self.label2?.attributedText = NSAttributedString(string: ReminderSection.LocalizedString.pause,
                                                                 font: .reminderSummaryPrimaryLabel)
            }
        }()
    }
}
