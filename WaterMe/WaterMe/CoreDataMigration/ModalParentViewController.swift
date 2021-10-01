//
//  ModalParentViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 14/1/18.
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

class ModalParentViewController: StandardViewController {

    @IBOutlet private weak var childVCContainerView: UIView!
    private var currentConstraints = [NSLayoutConstraint]()

    var childViewController: UIViewController?
    var configureChild: ((UIViewController) -> Void)?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initConfigure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initConfigure()
    }

    private func initConfigure() {
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overCurrentContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let grayView = UIView()
        grayView.backgroundColor = Style.grayViewColor
        grayView.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(grayView, belowSubview: self.childVCContainerView)
        self.view.addConstraints([
            grayView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1),
            grayView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1),
            grayView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            grayView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0)
            ])

        self.view.backgroundColor = .clear
        self.childVCContainerView.style_setCornerRadius()
        self.childVCContainerView.backgroundColor = Color.systemBackgroundColor
        self.childVCContainerView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        self.updateChildVCContainerViewConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.animateAlongSideTransitionCoordinator(animations: {
            self.childVCContainerView.transform = CGAffineTransform.identity
        }, completion: nil)
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.updateChildVCContainerViewConstraints(withNewTraitCollection: newCollection)
        }, completion: nil)
    }

    private func updateChildVCContainerViewConstraints(withNewTraitCollection traitCollection: UITraitCollection? = nil) {
        let tc = traitCollection ?? self.view.traitCollection
        let accessible = tc.preferredContentSizeCategory.isAccessibilityCategory

        let sub = self.childVCContainerView!
        let safe = self.view.safeAreaLayoutGuide

        let newConstraints: [NSLayoutConstraint]
        if accessible {
            newConstraints = [
                sub.leadingAnchor.constraint(equalToSystemSpacingAfter: safe.leadingAnchor, multiplier: 1),
                safe.trailingAnchor.constraint(equalToSystemSpacingAfter: sub.trailingAnchor, multiplier: 1),
                sub.topAnchor.constraint(equalToSystemSpacingBelow: safe.topAnchor, multiplier: 1),
                safe.bottomAnchor.constraint(equalToSystemSpacingBelow: sub.bottomAnchor, multiplier: 1)
            ]
        } else {
            switch (tc.verticalSizeClassIsRegular, tc.horizontalSizeClassIsCompact) {
            case (true, false):
                newConstraints = [
                    sub.centerXAnchor.constraint(equalTo: safe.centerXAnchor, constant: 0),
                    sub.centerYAnchor.constraint(equalTo: safe.centerYAnchor, constant: 0),
                    sub.widthAnchor.constraint(equalToConstant: 400),
                    sub.heightAnchor.constraint(equalToConstant: 400)
                ]
            case (true, _):
                newConstraints = [
                    sub.centerXAnchor.constraint(equalTo: safe.centerXAnchor, constant: 0),
                    sub.centerYAnchor.constraint(equalTo: safe.centerYAnchor, constant: 0),
                    sub.widthAnchor.constraint(equalTo: safe.widthAnchor, multiplier: 5 / 6),
                    sub.heightAnchor.constraint(equalTo: safe.heightAnchor, multiplier: 4 / 7)
                ]
            case (false, _):
                newConstraints = [
                    sub.centerXAnchor.constraint(equalTo: safe.centerXAnchor, constant: 0),
                    sub.centerYAnchor.constraint(equalTo: safe.centerYAnchor, constant: 0),
                    sub.widthAnchor.constraint(equalTo: safe.widthAnchor, multiplier: 1 / 2),
                    sub.heightAnchor.constraint(equalTo: safe.heightAnchor, multiplier: 1)
                ]
            }
        }

        self.currentConstraints.forEach({ $0.isActive = false })
        self.currentConstraints = newConstraints
        self.view.addConstraints(newConstraints)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.childViewController = segue.destination
        self.configureChild?(segue.destination)
    }

}
