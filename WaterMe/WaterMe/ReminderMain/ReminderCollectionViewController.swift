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

import Result
import RealmSwift
import WaterMeData
import UIKit

protocol ReminderCollectionViewControllerDelegate: class {
    func userDidSelectReminder(with identifier: Reminder.Identifier, from view: UIView, deselectAnimated: @escaping (Bool) -> Void, within viewController: ReminderCollectionViewController)
}

class ReminderCollectionViewController: StandardCollectionViewController, HasBasicController, HasProController {
    
    var proRC: ProController?
    var basicRC: BasicController?

    private(set) var reminders: ReminderGedeg?
    
    weak var delegate: ReminderCollectionViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.flow?.sectionHeadersPinToVisibleBounds = true
        self.flow?.headerReferenceSize = CGSize(width: 200, height: 40)
        self.collectionView?.contentInsetAdjustmentBehavior = .never
        self.collectionView?.dragInteractionEnabled = true // needed for iphone
        self.collectionView?.dragDelegate = self
        self.collectionView?.register(ReminderCollectionViewCell.nib,
                                      forCellWithReuseIdentifier: ReminderCollectionViewCell.reuseID)
        self.collectionView?.register(ReminderHeaderCollectionReusableView.nib,
                                      forSupplementaryViewOfKind: ReminderHeaderCollectionReusableView.kind,
                                      withReuseIdentifier: ReminderHeaderCollectionReusableView.reuseID)
        self.flow?.minimumInteritemSpacing = 0
        self.hardReloadData()
    }
    
    private func hardReloadData() {
        self.reminders = ReminderGedegDataSource(basicRC: self.basicRC, managedCollectionView: self.collectionView)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.reminders?.numberOfSections() ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.reminders?.numberOfItems(inSection: section) ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReminderCollectionViewCell.reuseID, for: indexPath)
        let reminder = self.reminders?.reminder(at: indexPath)
        if let reminder = reminder, let cell = cell as? ReminderCollectionViewCell {
            cell.configure(with: reminder)
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: ReminderHeaderCollectionReusableView.kind,
                                                                     withReuseIdentifier: ReminderHeaderCollectionReusableView.reuseID,
                                                                     for: indexPath)
        if let header = header as? ReminderHeaderCollectionReusableView, let section = ReminderSection(rawValue: indexPath.section) {
            header.setText(section.localizedTitleString)
        }
        return header
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let reminder = self.reminders?.reminder(at: indexPath), let cell = collectionView.cellForItem(at: indexPath) else { return }
        self.delegate?.userDidSelectReminder(with: .init(reminder: reminder),
                                             from: cell,
                                             deselectAnimated: { collectionView.deselectItem(at: indexPath, animated: $0) },
                                             within: self)

    }

    override var columnCount: Int {
        let accessibility = UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory
        let horizontalClass = self.view.traitCollection.horizontalSizeClass
        switch (horizontalClass, accessibility) {
        case (.unspecified, _):
            assertionFailure("Hit a size class this VC was not expecting")
            fallthrough
        case (.regular, false):
            return 2
        case (.regular, true):
            return 1
        case (.compact, false):
            return 2
        case (.compact, true):
            return 1
        }
    }

    override var itemHeight: CGFloat {
        return 180
    }
}

extension ReminderCollectionViewController: UICollectionViewDragDelegate {

    private func dragItemForReminder(at indexPath: IndexPath) -> UIDragItem? {
        guard let reminder = self.reminders?.reminder(at: indexPath) else { return nil }
        let item = UIDragItem(itemProvider: NSItemProvider())
        item.localObject = Reminder.Identifier(reminder: reminder)
        return item
    }

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [self.dragItemForReminder(at: indexPath)].flatMap({ $0 })
    }

    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return [self.dragItemForReminder(at: indexPath)].flatMap({ $0 })
    }

    func collectionView(_ collectionView: UICollectionView, dragSessionIsRestrictedToDraggingApplication session: UIDragSession) -> Bool {
        return false
    }
}
