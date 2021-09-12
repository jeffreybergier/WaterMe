//
//  UIViewController+WaterMe.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/25/18.
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

import UIKit
import ObjectiveC.runtime

private var DismissKey = UInt8.random(in: 0..<UInt8.max)

extension UIViewController {
    func dismissAnimatedIfNeeded(andThen completion: (() -> Void)?) {
        if self.presentedViewController != nil {
            self.dismissNoForReal(animated: true, completion: completion)
        } else {
            completion?()
        }
    }
    
    // For whatever reason, the `dismissViewController` method of UIVC does
    // different things when a view controller is being presented.
    // In situations where another VC is presented, this method just dismisses
    // the view controllers on top of itself and not itself.
    // This method just takes advantage of this and reaches down 1 level below
    // and asks that view controller to dismiss everything on top of it.
    // Stupid, I know...
    func dismissNoForReal(animated flag: Bool = true, completion: (() -> Void)? = nil) {
        // we only want this method to work once, so we'll associate a value with it
        // when the method is called and bail if we detect the object on the
        // subsequent passes
        let associated = objc_getAssociatedObject(self, &DismissKey) as? NSNumber
        if let associated = associated, associated.boolValue == true { return }
        objc_setAssociatedObject(self,
                                 &DismissKey,
                                 NSNumber(value: true),
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        if let presentingVC = self.presentingViewController {
            presentingVC.dismiss(animated: flag, completion: completion)
        } else {
            self.dismiss(animated: flag, completion: completion)
        }
    }

    func animateAlongSideTransitionCoordinator(animations: (() -> Void)?, completion: (() -> Void)?) {
        guard let tc = self.transitionCoordinator else {
            animations?()
            completion?()
            return
        }
        tc.animate(alongsideTransition: { _ in animations?() },
                   completion: { _ in completion?()})
    }
}
