//
//  ReminderVesselCollectionViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/31/17.
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

class ReminderVesselCollectionViewController: StandardCollectionViewController, HasBasicController {

    var vesselChosen: ((ReminderVessel) -> Void)?

    var basicRC: BasicController? {
        didSet {
            guard self.isViewLoaded else { return }
            self.hardReloadData()
        }
    }

    internal var data: Result<ReminderVesselCollection, DatumError>?

    override func viewDidLoad() {
        super.viewDidLoad()
        // support dark mode
        self.collectionView.backgroundColor = Color.systemBackgroundColor

        // configure collectionview
        self.collectionView?.register(ReminderVesselCollectionViewCell.nib,
                                      forCellWithReuseIdentifier: ReminderVesselCollectionViewCell.reuseID)
        self.flow?.minimumInteritemSpacing = 0

        // load data
        self.hardReloadData()
    }

    private func hardReloadData() {
      self.notificationToken?.invalidate()
        self.notificationToken = nil
        self.data = nil

        guard let result = self.basicRC?.allVessels(sorted: .displayName, ascending: true) else { return }
        switch result {
        case .failure(let error):
            self.data = .failure(error)
        case .success(let collection):
          self.notificationToken = collection.observe({ [weak self] changes in self?.dataChanged(changes) })
        }
    }

    private func dataChanged(_ changes: ReminderVesselCollectionChange) {
        switch changes {
        case .initial(let data):
            self.data = .success(data)
            self.collectionView?.reloadData()
        case .update(let updates):
            let updates = updates.transformed(newSection: 0)
            let (ins, dels, mods) = updates.ez
            self.collectionView?.performBatchUpdates({
                self.collectionView?.insertItems(at: ins)
                self.collectionView?.deleteItems(at: dels)
                self.collectionView?.reloadItems(at: mods)
            }, completion: nil)
        case .error(let error):
            Analytics.log(error: error)
            error.log()
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data?.value?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReminderVesselCollectionViewCell.reuseID, for: indexPath)
        if let vessel = self.data?.value?[indexPath.row], let cell = cell as? ReminderVesselCollectionViewCell {
            cell.configure(with: vessel)
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vessel = self.data?.value?[indexPath.row] else { return }
        self.vesselChosen?(vessel)
    }

    override var columnCountAndItemHeight: (columnCount: Int, itemHeight: CGFloat) {
        let width = self.collectionView?.availableContentSize.width ?? 0
        let tc = self.view.traitCollection
        let math = type(of: self).columnCountAndItemHeight(withWidth:columnCount:)
        switch (tc.horizontalSizeClassIsCompact,
                tc.preferredContentSizeCategory.isAccessibilityCategory)
        {
        case (true, false):
            return math(width, 2)
        case (true, true):
            return math(width, 1)
        case (false, false):
            return math(width, 4)
        case (false, true):
            return math(width, 2)
        }
    }

    private var notificationToken: ObservationToken?

    deinit {
      self.notificationToken?.invalidate()
    }

}
