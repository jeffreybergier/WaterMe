//
//  SettingsTableViewController.swift
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
import StoreKit
import Datum
import Store
import UIKit

class SettingsTableViewController: StandardTableViewController {

    var settingsRowChosen: ((SettingsRows, ((Bool) -> Void)?) -> Void)?
    var tipJarRowChosen: ((TipJarRowSelection, ((Bool) -> Void)?) -> Void)?
    var products: TipJarProducts? {
        didSet {
            self.tableView.reloadSections(IndexSet([Sections.tipJar.rawValue]), with: .automatic)
        }
    }
    var avatarIcon: ReminderVesselIcon? {
        didSet {
            self.tableView.reloadRows(at: [IndexPath(row: TipJarRows.info.rawValue, section: Sections.tipJar.rawValue)], with: .automatic)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
        self.tableView.register(SimpleLabelTableViewCell.self, forCellReuseIdentifier: SimpleLabelTableViewCell.reuseID)
        self.tableView.register(SettingsTipJarTableViewCell.self, forCellReuseIdentifier: SettingsTipJarTableViewCell.reuseID)
        self.tableView.register(SettingsInfoTableViewCell.nib, forCellReuseIdentifier: SettingsInfoTableViewCell.reuseID)
        URLSession.shared.downloadAvatar { [weak self] icon in
            self?.avatarIcon = icon
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Sections(rawValue: section) else { assertionFailure("Wrong Section"); return 0 }
        switch section {
        case .settings:
            return SettingsRows.count
        case .tipJar:
            return TipJarRows.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let (_, row) = Sections.sectionsAndRows(from: indexPath) else { fatalError("Wrong Section/Row") }
        switch row {
        case .left(let row):
            let _cell = tableView.dequeueReusableCell(withIdentifier: SimpleLabelTableViewCell.reuseID, for: indexPath)
            guard let cell = _cell as? SimpleLabelTableViewCell else { return _cell }
            cell.label.attributedText = NSAttributedString(string: row.localizedTitle, font: .selectableTableViewCell)
            cell.accessoryType = .disclosureIndicator
            return cell
        case .right(let row):
            switch row {
            case .info:
                let _cell = tableView.dequeueReusableCell(withIdentifier: SettingsInfoTableViewCell.reuseID, for: indexPath)
                guard let cell = _cell as? SettingsInfoTableViewCell else { return _cell }
                cell.configure(with: self.avatarIcon, and: SettingsMainViewController.LocalizedString.cellTitleInfo)
                return cell
            case .free, .large, .medium, .small:
                let _cell = tableView.dequeueReusableCell(withIdentifier: SettingsTipJarTableViewCell.reuseID, for: indexPath)
                guard let cell = _cell as? SettingsTipJarTableViewCell else { return _cell }
                cell.configure(with: row, product: row.product(from: self.products))
                return cell
            }
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Sections(rawValue: section) else { assertionFailure("Wrong Section"); return nil; }
        return section.localizedTitle
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let (_, row) = Sections.sectionsAndRows(from: indexPath) else { assertionFailure("Wrong Section/Row"); return false; }
        switch row {
        case .left:
            return true
        case .right(let row):
            switch row {
            case .info:
                return false
            case .free:
                return true
            case .large, .medium, .small:
                return self.products != nil ? true : false
            }
        }
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let (_, row) = Sections.sectionsAndRows(from: indexPath) else { assertionFailure("Wrong Section/Row"); return nil; }
        switch row {
        case .left:
            // always let the user select a settings row
            return indexPath
        case .right(let row):
            switch row {
            case .info:
                // never let the user select the info cell
                return nil
            case .free:
                // always let the user select the free row
                return indexPath
            case .large, .medium, .small:
                // for the IAPs, only let the user select them if there is a product retrieved from the network
                return self.products != nil ? indexPath : nil
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let (_, row) = Sections.sectionsAndRows(from: indexPath) else { assertionFailure("Wrong Section/Row"); return; }
        let completion: ((Bool) -> Void)? = { tableView.deselectRow(at: indexPath, animated: $0) }
        switch row {
        case .left(let row):
            self.settingsRowChosen?(row, completion)
        case .right(let row):
            guard let selection = TipJarRowSelection(row: row, products: self.products) else { return }
            self.tipJarRowChosen?(selection, completion)
        }
    }
}

extension SettingsTableViewController {
    fileprivate enum Sections: Int {
        static let count = 2
        case settings, tipJar
        var localizedTitle: String {
            switch self {
            case .settings:
                return SettingsMainViewController.LocalizedString.settingsTitle
            case .tipJar:
                return SettingsMainViewController.LocalizedString.title
            }
        }
        static func sectionsAndRows(from indexPath: IndexPath) -> (Sections, Either<SettingsRows, TipJarRows>)? {
            guard let section = Sections(rawValue: indexPath.section) else { assertionFailure("Wrong Section"); return nil; }
            switch section {
            case .settings:
                guard let rows = SettingsRows(rawValue: indexPath.row) else { assertionFailure("Wrong Rows"); return nil; }
                return (section, .left(rows))
            case .tipJar:
                guard let rows = TipJarRows(rawValue: indexPath.row) else { assertionFailure("Wrong Rows"); return nil; }
                return (section, .right(rows))
            }
        }
    }

    enum SettingsRows: Int {
        static let count = 2
        case openSettings, emailDeveloper
        var localizedTitle: String {
            switch self {
            case .openSettings:
                return SettingsMainViewController.LocalizedString.cellTitleOpenSettings
            case .emailDeveloper:
                return SettingsMainViewController.LocalizedString.cellTitleEmailDeveloper
            }
        }
    }

    enum TipJarRows: Int {
        static let count = 5
        case info, free, small, medium, large
        func product(from products: TipJarProducts?) -> SKProduct? {
            switch self {
            case .free, .info:
                return nil
            case .small:
                return products?.small
            case .medium:
                return products?.medium
            case .large:
                return products?.large
            }
        }
    }

    enum TipJarRowSelection {
        case free, small(SKProduct), medium(SKProduct), large(SKProduct)
        init?(row: TipJarRows, products: TipJarProducts?) {
            if case .free = row {
                self = .free
                return
            }
            guard let products = products else { return nil }
            switch row {
            case .free, .info:
                assertionFailure()
                return nil
            case .small:
                self = .small(products.small)
            case .medium:
                self = .medium(products.medium)
            case .large:
                self = .large(products.large)
            }
        }
    }
}

extension URLSession {
    func downloadAvatar(completion: @escaping (ReminderVesselIcon?) -> Void) {
        guard let kAvatarURL = PrivateKeys.kAvatarURL else {
            "PrivateKeys.kAvatarURL was NIL".log()
            completion(nil)
            return
        }
        let request = URLRequest(url: kAvatarURL)
        let task = self.dataTask(with: request) { data, response, error in
            guard
                error == nil,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data,
                let image = UIImage(data: data)
            else {
                "Unable to download avatar image".log(as: .info)
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            let icon = ReminderVesselIcon(rawImage: image)
            DispatchQueue.main.async {
                completion(icon)
            }
        }
        task.resume()
    }
}
