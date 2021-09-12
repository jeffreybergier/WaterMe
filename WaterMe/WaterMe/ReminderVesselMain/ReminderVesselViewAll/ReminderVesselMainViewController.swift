//
//  ReminderVesselMainViewController.swift
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

class ReminderVesselMainViewController: StandardViewController, HasProController, HasBasicController {

    class func newVC(basicController: BasicController?,
                     proController: ProController? = nil,
                     completionHandler: @escaping (UIViewController) -> Void) -> UINavigationController {
        let sb = UIStoryboard(name: "ReminderVesselMain", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let navVC = sb.instantiateInitialViewController() as! UINavigationController
        // swiftlint:disable:next force_cast
        var vc = navVC.viewControllers.first as! ReminderVesselMainViewController
        vc.title = LocalizedString.title // set here because it works better in UITabBarController
        vc.configure(with: basicController)
        vc.configure(with: proController)
        vc.completionHandler = completionHandler
        navVC.presentationController?.delegate = vc
        return navVC
    }
    
    /*@IBOutlet*/ private weak var collectionVC: ReminderVesselCollectionViewController?

    private lazy var doneBBI: UIBarButtonItem = UIBarButtonItem(localizedDoneButtonWithTarget: self,
                                                                action: #selector(self.doneButtonTapped(_:)))
    private lazy var addReminderVesselBBI: UIBarButtonItem = UIBarButtonItem(__legacy_localizedAddReminderVesselBBIButtonWithTarget: self,
                                                                             action: #selector(self.addReminderVesselButtonTapped(_:)))
    
    var basicRC: BasicController?
    var proRC: ProController?

    private var completionHandler: ((UIViewController) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = self.addReminderVesselBBI
        self.navigationItem.rightBarButtonItem = self.doneBBI
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Analytics.log(viewOperation: .reminderVesselList)

        if let data = self.collectionVC?.data, case .failure(let error) = data {
            self.collectionVC?.data = nil
            UIAlertController.presentAlertVC(for: error, over: self)
        }
    }
    
    @IBAction private func addReminderVesselButtonTapped(_ sender: NSObject?) {
        self.editReminderVessel(nil)
    }

    @IBAction private func doneButtonTapped(_ sender: Any) {
        self.completionHandler?(self)
    }
    
    private func editReminderVessel(_ vessel: ReminderVessel?) {
        guard let basicRC = self.basicRC else { return }
        let deselectAction: (() -> Void)? = vessel == nil ? nil : { self.collectionVC?.collectionView?.deselectAllItems(animated: true) }
        let editVC = ReminderVesselEditViewController.newVC(basicController: basicRC, editVessel: vessel) { vc in
            vc.dismissNoForReal(completion: deselectAction)
        }
        self.present(editVC, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var destVC = segue.destination as? ReminderVesselCollectionViewController {
            self.collectionVC = destVC
            destVC.vesselChosen = { [unowned self] in self.editReminderVessel($0) }
            destVC.configure(with: self.basicRC)
        }
    }
}

extension ReminderVesselMainViewController /* UIAdaptivePresentationControllerDelegate */ {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.completionHandler?(self)
    }
}
