//
//  UITableCollectionView+WaterMe.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/20/18.
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

import DatumL
import UIKit

extension UICollectionView {
    func deselectAllItems(animated: Bool) {
        let indexPaths = self.indexPathsForSelectedItems
        indexPaths?.forEach({ self.deselectItem(at: $0, animated: animated) })
    }
    var availableContentSize: CGSize {
        let insets = self.adjustedContentInset
        let width = self.bounds.width - insets.left - insets.right
        let height = self.bounds.height - insets.top - insets.bottom
        return CGSize(width: width, height: height)
    }
}

// Extensions for ReminderGedeg
extension UICollectionView: ItemAndSectionable {}
extension UITableView: ItemAndSectionable {
    public func numberOfItems(inSection section: Int) -> Int {
        return self.numberOfRows(inSection: section)
    }
}

// Extensions for ReminderSummary Screen
extension UITableView {

    public var lastIndexPath: IndexPath? {
        let lastSection = self.numberOfSections - 1
        guard lastSection >= 0 else { return nil }
        let lastRow = self.numberOfRows(inSection: lastSection) - 1
        guard lastRow >= 0 else { return nil }
        return IndexPath(row: lastRow, section: lastSection)
    }

    public var allRowsVisible: Bool {
        let visibleIndexPaths = self.indexPathsForVisibleRows ?? []
        guard visibleIndexPaths.isEmpty == false else { return false }
        let numberOfSections = self.dataSource?.numberOfSections?(in: self) ?? 0
        guard numberOfSections > 0 else { return false }
        let numberOfRows = (0..<numberOfSections).reduce(0)
        { (prevValue, section) -> Int in
            let numberOfRows = self.dataSource?.tableView(self, numberOfRowsInSection: section) ?? 0
            return numberOfRows + prevValue
        }
        let test = numberOfRows == visibleIndexPaths.count
        return test
    }

    public var visibleRowsSize: CGSize {
        let visibleIndexPaths = self.indexPathsForVisibleRows ?? []
        guard visibleIndexPaths.isEmpty == false else { return .zero }
        let sections = Set(visibleIndexPaths.map({ return $0.section }))
        let sectionHeaderFooterHeights = sections.reduce(0)
        { (lastValue, section) -> CGFloat in
            let headerView = self.headerView(forSection: section)
            let footerView = self.footerView(forSection: section)
            return lastValue +
                (headerView?.frame.height ?? 0)  +
                (footerView?.frame.height ?? 0)
        }
        let rowHeights = visibleIndexPaths.reduce(0)
        { (lastValue, indexPath) -> CGFloat in
            let _cellView = self.cellForRow(at: indexPath)
            guard let cellView = _cellView else { return lastValue }
            return lastValue + cellView.frame.height
        }
        let tableHeaderFooterHeights = { () -> CGFloat in
            let headerView = self.tableHeaderView
            let footerView = self.tableFooterView
            return (headerView?.frame.height ?? 0) + (footerView?.frame.height ?? 0)
        }()
        let width = self.frame.width
        let height = sectionHeaderFooterHeights + rowHeights + tableHeaderFooterHeights
        return CGSize(width: width, height: height)
    }

    public func scrollToBottom(_ animated: Bool) {
        guard let lastIndexPath = self.lastIndexPath else { return }
        self.scrollToRow(at: lastIndexPath, at: .top, animated: animated)
    }
}
