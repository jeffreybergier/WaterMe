//
//  ReminderCollectionViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 08/10/17.
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
import UIKit

protocol ReminderCollectionViewControllerDelegate: AnyObject {
    func userDidSelect(reminderID: Identifier,
                       from view: UIView,
                       userActivityContinuation: NSUserActivityContinuedHandler?,
                       deselectAnimated: ((Bool) -> Void)?,
                       within viewController: ReminderCollectionViewController)
    func dragSessionWillBegin(_ session: UIDragSession,
                              within viewController: ReminderCollectionViewController)
    func dragSessionDidEnd(_ session: UIDragSession,
                           within viewController: ReminderCollectionViewController)
    func forceUpdateCollectionViewInsets()
}

class ReminderCollectionViewController: StandardCollectionViewController, HasBasicController, HasProController {

    var proRC: ProController?
    var basicRC: BasicController?
    var allDataReady: ((Bool) -> Void)?

    var reminders: Result<GroupedReminderCollection, DatumError>?
    private let significantTimePassedDetector = SignificantTimePassedDetector()
    weak var delegate: ReminderCollectionViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // update if significant time passes
        self.significantTimePassedDetector.delegate = self

        // part of a hack that sometimes requires the collectionview to be replaced
        self.replaceCollectionView()

        // configure the collectionview
        self.configureCollectionView()

        // load data
        self.hardReloadData()
    }

    private func replaceCollectionView() {
        let flow = self.collectionView?.collectionViewLayout ?? UICollectionViewFlowLayout()
        // flow must be invalidated because it might have been in the middle of something
        // when we replaced the collectionView
        flow.invalidateLayout()
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: flow)
    }

    private func configureCollectionView() {
        // needed so autoadjustment happens on both axes all the time
        // the default is to only adjust on vertical axes
        self.collectionView?.contentInsetAdjustmentBehavior = .always
        // not sure why this is not the default
        self.collectionView?.alwaysBounceVertical = true
        // disabled by default on iphone
        self.collectionView?.dragInteractionEnabled = true
        self.collectionView?.dragDelegate = self
        self.collectionView?.register(ReminderCollectionViewCell.nib,
                                      forCellWithReuseIdentifier: ReminderCollectionViewCell.reuseID)
        self.collectionView?.register(ReminderHeaderCollectionReusableView.self,
                                      forSupplementaryViewOfKind: ReminderHeaderCollectionReusableView.kind,
                                      withReuseIdentifier: ReminderHeaderCollectionReusableView.reuseID)
        // makes the section headers work like a tableview
        self.flow?.sectionHeadersPinToVisibleBounds = true
        // make everything as tight as possible on the screen
        self.flow?.minimumInteritemSpacing = 0
        self.flow?.minimumLineSpacing = 0
        // support dark mode
        self.collectionView.backgroundColor = Color.systemBackgroundColor
    }

    private var token: ObservationToken?

    private func hardReloadData() {
        self.token?.invalidate()
        self.token = nil
        self.reminders = nil
        self.collectionView.reloadData()
        guard let result = self.basicRC?.groupedReminders() else { return }
        switch result {
        case .failure(let error):
            self.allDataReady?(false)
            self.reminders = .failure(error)
        case .success(let query):
            self.token = query.observe { [weak self] in self?.remindersChanged($0) }
        }
    }

    private func remindersChanged(_ change: GroupedReminderCollectionChange) {
        switch change {
        case .initial(let data):
            self.reminders = .success(data)
            self.collectionView.reloadData()
            self.allDataReady?(true)
        case .update(let updates):
            let (ins, dels, mods) = updates.ez
            self.performSuperSafeCollectionViewUpdate(insertions: ins,
                                                      deletions: dels,
                                                      modifications: mods)
        case .error(let error):
            self.reminders = nil
            UIAlertController.presentAlertVC(for: error, over: self, completionHandler: nil)
        }
    }

    func programmaticalySelectReminder(with identifier: Identifier) -> (IndexPath, ((Bool) -> Void))? {
        guard
            let collectionView = self.collectionView,
            let indexPath = self.reminders?.value?.indexOfItem(with: identifier)
        else { return nil }
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
        return (indexPath, { collectionView.deselectItem(at: indexPath, animated: $0) })
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.reminders?.value?.numberOfSections ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.reminders?.value?.count(at: IndexPath(row: 0, section: section)) ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReminderCollectionViewCell.reuseID, for: indexPath)
        let reminder = self.reminders?.value?[indexPath]
        if let reminder = reminder, let cell = cell as? ReminderCollectionViewCell {
            cell.configure(with: reminder)
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: ReminderHeaderCollectionReusableView.kind,
                                                                     withReuseIdentifier: ReminderHeaderCollectionReusableView.reuseID,
                                                                     for: indexPath)
        if let header = header as? ReminderHeaderCollectionReusableView,
            let section = ReminderSection(rawValue: indexPath.section)
        {
            header.section = section
        }
        return header
    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // we don't want the user to be able to select a cell when a drag is active
        guard collectionView.hasActiveDrag == false else { return false }
        return true
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard
            let reminder = self.reminders?.value?[indexPath],
            let cell = collectionView.cellForItem(at: indexPath)
        else { return }
        let identifier = Identifier(rawValue: reminder.uuid)
        self.delegate?.userDidSelect(reminderID: identifier,
                                     from: cell,
                                     userActivityContinuation: nil,
                                     deselectAnimated: { collectionView.deselectItem(at: indexPath, animated: $0) },
                                     within: self)
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as? ReminderCollectionViewCell
        cell?.willDisplay()
    }

    override var columnCountAndItemHeight: (columnCount: Int, itemHeight: CGFloat) {
        let tc = self.view.traitCollection
        switch (tc.horizontalSizeClassIsCompact,
                tc.verticalSizeClassIsRegular,
                tc.preferredContentSizeCategory.isAccessibilityCategory)
        {
        case (true, true, false): // iPhone Portrait, no Accessibility
            return (2, 200)
        case (true, true, true): // iPhone Portrait, w/ Accessibility
            return (1, 320)
        case (true, false, false): // iPhone Landscape, no Accessibility
            return (2, 200)
        case (true, false, true): // iPhone Landscape, w/ Accessibility
            return (1, 320)
        case (false, false, false): // iPhone+ Landscape, no Accessibility
            return (3, 200)
        case (false, false, true): // iPhone+ Landscape, w/ Accessibility
            return (2, 320)
        case (false, true, false): // iPad No Accessibility
            return (4, 200)
        case (false, true, true): // iPad w/ Accessibility
            return (2, 320)
        }
    }

    deinit {
        self.token?.invalidate()
    }
}

extension ReminderCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        let kind = ReminderHeaderCollectionReusableView.self
        let count = self.reminders?.value?.count(at: IndexPath(row: 0, section: section)) ?? 0
        guard count > 0 else {
            // if I return height of 0 here, things crash
            // instead I'll just have to set the alpha to 0
            return CGSize(width: collectionView.availableContentSize.width, height: 1)
        }
        let isAC = self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        return CGSize(
            width: collectionView.availableContentSize.width,
            height: kind.style_viewHeight(isAccessibilityCategory: isAC)
        )
    }
}

extension ReminderCollectionViewController: UICollectionViewDragDelegate {

    private func dragItemForReminder(at indexPath: IndexPath) -> UIDragItem? {
        guard let reminder = self.reminders?.value?[indexPath] else { return nil }
        let item = UIDragItem(itemProvider: NSItemProvider())
        // only make the "small" preview show on iPhones. On iPads, there is plenty of space
        let tc = self.view.traitCollection
        switch (tc.horizontalSizeClassIsCompact, tc.verticalSizeClassIsRegular) {
        case (false, true):
            break // do nothing for ipads
        default:
            item.previewProvider = { ReminderDragPreviewView.dragPreview(for: reminder) }
        }
        item.localObject = ReminderAndVesselValue(reminder: reminder)
        return item
    }

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [self.dragItemForReminder(at: indexPath)].compactMap({ $0 })
    }

    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return [self.dragItemForReminder(at: indexPath)].compactMap({ $0 })
    }

    func collectionView(_ collectionView: UICollectionView, dragSessionIsRestrictedToDraggingApplication session: UIDragSession) -> Bool {
        return false
    }

    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return nil }
        let p = UIDragPreviewParameters()
        p.visiblePath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: UIApplication.style_cornerRadius)
        return p
    }

    func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession) {
        self.delegate?.dragSessionWillBegin(session, within: self)
    }

    func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
        self.delegate?.dragSessionDidEnd(session, within: self)
    }
}

extension ReminderCollectionViewController: SignificantTimePassedDetectorDelegate {
    func significantTimeDidPass(with reason: SignificantTimePassedDetector.Reason,
                                detector _: SignificantTimePassedDetector)
    {
        switch reason {
        case .STCNotification:
            Analytics.log(event: Analytics.Event.stpReloadNotification)
        }
        "Reloading Data...".log(as: .info)
        self.hardReloadData()
    }
}

extension ReminderCollectionViewController {
    func performSuperSafeCollectionViewUpdate(insertions     ins: [IndexPath],
                                              deletions     dels: [IndexPath],
                                              modifications mods: [IndexPath])
    {
        guard let reminders = self.reminders?.value, let cv = self.collectionView else {
            let error = "CollectionView or Reminders are NIL. Something really bad happened."
            error.log()
            assertionFailure(error)
            self.collectionView?.reloadData()
            return
        }
        let allEmpty = ins.isEmpty && dels.isEmpty && mods.isEmpty
        guard allEmpty == false else {
            // there is nothing to be done, so bail out early
            return
        }
        guard cv.window != nil else {
            // we're not in the view hierarchy
            // no need for animated stuff to happen
            cv.reloadData()
            return
        }

        let failureReason = ItemAndSectionSanityCheckFailureReason.check(old: cv,
                                                                         new: reminders,
                                                                         delta: (ins, dels))

        guard failureReason == nil else {
            let error = NSError(errorFromSanityCheckFailureReason: failureReason!)
            Analytics.log(error: error)
            error.log(as: .notice)
            cv.reloadData()
            return
        }
        TCF.try({
            cv.performBatchUpdates({
                cv.insertItems(at: ins)
                cv.deleteItems(at: dels)
                cv.reloadItems(at: mods)
            }, completion: { success in
                guard success == false else { return }
                "CollectionView failed to Reload Sections: This usually happens when data changes really fast".log(as: .notice)
                cv.reloadData()
            })
        }, shouldCatch: { exception in
            guard case .internalInconsistencyException = exception.name else {
                return false
            }
            let error = NSError(collectionViewBatchUpdateException: exception)
            Analytics.log(error: error)
            error.log(as: .notice)
            return true
        }, finally: { exceptionWasCaught in
            guard exceptionWasCaught == true else { return }
            self.replaceDamagedCollectionView()
        })
    }

    private func replaceDamagedCollectionView() {
        self.replaceCollectionView()
        self.configureCollectionView()
        self.delegate?.forceUpdateCollectionViewInsets()
        self.hardReloadData()
    }
}
