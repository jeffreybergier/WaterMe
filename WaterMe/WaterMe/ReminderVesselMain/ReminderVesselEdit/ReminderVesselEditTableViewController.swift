//
//  ReminderVesselEditTableViewController.swift
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

import Datum
import UIKit
import Calculate

protocol ReminderVesselEditTableViewControllerDelegate: AnyObject {
    var vesselResult: Result<ReminderVessel, DatumError>? { get }
    func userChangedName(to: String, controller: ReminderVesselEditTableViewController?)
    func userChoseAddReminder(controller: ReminderVesselEditTableViewController?)
    func userChosePhotoChange(controller: ReminderVesselEditTableViewController?,
                              sender: PopoverSender)
    func userChose(reminder: Reminder,
                   deselectRowAnimated: ((Bool) -> Void)?,
                   controller: ReminderVesselEditTableViewController?)
    func userChose(siriShortcut: ReminderVesselEditTableViewController.SiriShortcut,
                   deselectRowAnimated: ((Bool) -> Void)?,
                   controller: ReminderVesselEditTableViewController?)
    func userDeleted(reminder: Reminder,
                     controller: ReminderVesselEditTableViewController?) -> Bool
    func userToggled(reminder: Reminder,
                     controller: ReminderVesselEditTableViewController?) -> Bool
}

class ReminderVesselEditTableViewController: StandardTableViewController {
    
    weak var delegate: ReminderVesselEditTableViewControllerDelegate?
    
    func reloadPhotoAndName() {
        self.tableView.reloadSections(IndexSet([Section.photo.rawValue,
                                                Section.name.rawValue]),
                                      with: .automatic)
    }
    
    func reloadAll() {
        self.invalidateTokens()
        self.tableView.reloadData()
        self.notificationToken = self.delegate?.vesselResult?.value?.observeReminders
            { [weak self] in
                self?.remindersChanged($0)
            }
    }
    
    func reloadReminders() {
        self.invalidateTokens()
        self.tableView.reloadSections(IndexSet([Section.reminders.rawValue]), with: .automatic)
        self.notificationToken = self.delegate?.vesselResult?.value?.observeReminders
            { [weak self] in
                self?.remindersChanged($0)
            }
    }
    
    func nameTextFieldBecomeFirstResponder() {
        let indexPath = IndexPath(row: 0, section: Section.name.rawValue)
        UIView.style_animateNormal({
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }, completion: { _ in
            let cell = self.tableView.cellForRow(at: indexPath) as? TextFieldTableViewCell
            cell?.textFieldBecomeFirstResponder()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
        self.tableView.register(ReminderTableViewCell.nib,
                                forCellReuseIdentifier: ReminderTableViewCell.reuseID)
        self.tableView.register(TextFieldTableViewCell.nib,
                                forCellReuseIdentifier: TextFieldTableViewCell.reuseID)
        self.tableView.register(SiriShortcutTableViewCell.self,
                                forCellReuseIdentifier: SiriShortcutTableViewCell.reuseID)
        self.tableView.register(OptionalAddButtonTableViewHeaderFooterView.nib,
                                forHeaderFooterViewReuseIdentifier: OptionalAddButtonTableViewHeaderFooterView.reuseID)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 40
        self.reloadAll()
    }
    
    private var remindersData: ReminderCollection?
    
    private func remindersChanged(_ changes: ReminderCollectionChange) {
        switch changes {
        case .initial(let data):
            self.remindersData = data
            self.tableView.reloadSections(IndexSet([Section.reminders.rawValue]), with: .automatic)
        case .update(let updates):
            let updates = updates.transformed(newSection: Section.reminders.rawValue)
            let (ins, dels, mods) = updates.ez
            guard self.delegate?.vesselResult != nil, self.remindersData != nil else {
                let error = NSError(reminderChangeFiredAfterListOrParentVesselWereSetToNil: nil)
                assertionFailure(String(describing: error))
                Analytics.log(error: error)
                error.log()
                return
            }
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: ins, with: .automatic)
            self.tableView.deleteRows(at: dels, with: .automatic)
            self.tableView.reloadRows(at: mods, with: .automatic)
            self.tableView.endUpdates()
        case .error(let error):
            Analytics.log(error: error)
            error.log()
            self.reloadReminders()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int
    {
        guard let section = Section(rawValue: section) else {
            assertionFailure("Unknown Section")
            return 0
        }
        switch section {
        case .name:
            return 1
        case .photo:
            return 1
        case .reminders:
            // swiftlint:disable:next todo
            // FIXME: Crasher Workaround - http://crashes.to/s/44d5e5cef85
            // this was sometimes causing a crash because the underlying object was deleted
            // But in reality the underlying object should always be set to NIL if it gets deleted
            let data = self.remindersData
            
            // TODO: Removing this because Core Data doesn't have this concept
            /*
            let invalidated = data?.isInvalidated ?? false
            guard invalidated == false else {
                let error = NSError(underlyingObjectInvalidated: nil)
                assertionFailure(String(describing: error))
                error.log()
                Analytics.log(error: error)
                return 0
            }
            */
            
            return data?.count ?? 0
        case .siriShortcuts:
            return SiriShortcut.allCases.count
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let section = Section(rawValue: indexPath.section) else {
            assertionFailure("Unknown Section")
            return UITableViewCell()
        }
        switch section {
        case .name:
            let id = TextFieldTableViewCell.reuseID
            let _cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            let cell = _cell as? TextFieldTableViewCell
            cell?.setTextField(text: self.delegate?.vesselResult?.value?.displayName)
            cell?.setLabelText(nil, andTextFieldPlaceHolderText: "Plant Name")
            cell?.textChanged = { [unowned self] newName in
                self.delegate?.userChangedName(to: newName, controller: self)
            }
            return _cell
        case .photo:
            let id = ReminderVesselIconTableViewCell.reuseID
            let _cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            let cell = _cell as? ReminderVesselIconTableViewCell
            cell?.configure(with: self.delegate?.vesselResult?.value?.icon)
            cell?.iconButtonTapped = { [unowned self] sender in
                self.delegate?.userChosePhotoChange(controller: self, sender: .left((sender, .center)))
            }
            return _cell
        case .reminders:
            let id = ReminderTableViewCell.reuseID
            let _cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            let cell = _cell as? ReminderTableViewCell
            cell?.configure(with: self.remindersData?[indexPath.row])
            return _cell
        case .siriShortcuts:
            let id = SiriShortcutTableViewCell.reuseID
            let _cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            guard
                let cell = _cell as? SiriShortcutTableViewCell,
                let row = SiriShortcut(rawValue: indexPath.row)
            else { return _cell }
            switch row {
            case .editReminderVessel:
                cell.configure(withLocalizedTitle: row.localizedTitle)
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath)
    {
        guard let section = Section(rawValue: indexPath.section) else {
            assertionFailure("Unknown Section")
            return
        }
        switch section {
        case .name, .photo:
            break
        case .reminders:
            guard let reminder = self.remindersData?[indexPath.row] else { return }
            self.delegate?.userChose(reminder: reminder, deselectRowAnimated: { anim in
                tableView.deselectRow(at: indexPath, animated: anim)
            }, controller: self)
        case .siriShortcuts:
            guard let row = ReminderVesselEditTableViewController.SiriShortcut(rawValue: indexPath.row) else { return }
            self.delegate?.userChose(siriShortcut: row, deselectRowAnimated: { anim in
                tableView.deselectRow(at: indexPath, animated: anim)
            }, controller: self)
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        // These actions cause a visual bug in iOS 12 and lower
        guard #available(iOS 13, *) else {
            return UISwipeActionsConfiguration(actions: [])
        }

        guard let section = Section(rawValue: indexPath.section) else {
            assertionFailure("Unknown Section")
            return UISwipeActionsConfiguration(actions: [])
        }
        switch section {
        case .name, .photo:
            return UISwipeActionsConfiguration(actions: [])
        case .reminders:
            let deleteAction = UIContextualAction(style: .destructive,
                                                  title: UIAlertController.LocalizedString.buttonTitleDelete)
            { [unowned self] _, _, successfullyDeleted in
                let cell = tableView.cellForRow(at: indexPath)
                let sender = cell.map { PopoverSender.left(($0, .topTrailing)) }
                let confirmation = UIAlertController(localizedDeleteConfirmationWithOptions: [],
                                                     sender: sender)
                { confirmed in
                    switch confirmed {
                    case .cancel, .pause:
                        successfullyDeleted(false)
                    case .delete:
                        guard let reminder = self.remindersData?[indexPath.row] else {
                            successfullyDeleted(false)
                            return
                        }
                        let deleted = self.delegate?.userDeleted(reminder: reminder, controller: self) ?? false
                        successfullyDeleted(deleted)
                    }
                }
                self.present(confirmation, animated: true, completion: nil)
            }

            let pauseAction = UIContextualAction(style: .normal,
                                                 title: (self.remindersData?[indexPath.row]?.isEnabled ?? true)
                                                    ? UIAlertController.LocalizedString.buttonTitlePauseShort
                                                    : UIAlertController.LocalizedString.buttonTitleUnpauseShort)
            { [unowned self] _, _, successfullyToggled in
                guard let reminder = self.remindersData?[indexPath.row] else {
                    successfullyToggled(false)
                    return
                }
                let toggled = self.delegate?.userToggled(reminder: reminder, controller: self) ?? false
                successfullyToggled(toggled)
            }
            
            return UISwipeActionsConfiguration(actions: [deleteAction, pauseAction])
        case .siriShortcuts:
            return UISwipeActionsConfiguration(actions: [])
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            viewForHeaderInSection section: Int) -> UIView?
    {
        guard let section = Section(rawValue: section) else {
            assertionFailure("Unknown Section")
            return nil
        }
        let id = OptionalAddButtonTableViewHeaderFooterView.reuseID
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: id)
            as? OptionalAddButtonTableViewHeaderFooterView
        switch section {
        case .name, .photo, .siriShortcuts:
            view?.isAddButtonHidden = true
            view?.addButtonTapped = nil
        case .reminders:
            view?.isAddButtonHidden = false
            view?.addButtonTapped = { [unowned self] in
                self.delegate?.userChoseAddReminder(controller: self)
            }
        }
        return view
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(false)
    }
    
    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String?
    {
        guard let section = Section(rawValue: section) else {
            assertionFailure("Unknown Section")
            return nil
        }
        return section.localizedTitle
    }
    
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    func invalidateTokens() {
        self.notificationToken?.invalidate()
        self.notificationToken = nil
        self.remindersData = nil
        self.tableView.reloadData()
    }
    
    private var notificationToken: ObservationToken?
    
    deinit {
        self.notificationToken?.invalidate()
    }
}

extension ReminderVesselEditTableViewController {
    private enum Section: Int, CaseIterable {
        case photo = 0, name, reminders, siriShortcuts
        var localizedTitle: String {
            switch self {
            case .photo:
                return LocalizedString.ReminderVessel.photo
            case .name:
                return LocalizedString.ReminderVessel.name
            case .reminders:
                return LocalizedString.ReminderVessel.reminders
            case .siriShortcuts:
                return "Siri Shortcuts"
            }
        }
    }

    enum SiriShortcut: Int, CaseIterable {
        case editReminderVessel
        var localizedTitle: String {
            switch self {
            case .editReminderVessel:
                return "Edit This Plant"
            }
        }
    }
}
