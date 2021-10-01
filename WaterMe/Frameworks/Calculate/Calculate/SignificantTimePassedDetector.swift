//
//  SignificantTimePassedDetector.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 7/2/18.
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

public protocol SignificantTimePassedDetectorDelegate: AnyObject {
    func significantTimeDidPass(with reason: SignificantTimePassedDetector.Reason,
                                detector: SignificantTimePassedDetector)
}

public class SignificantTimePassedDetector {

    public enum Reason {
        case STCNotification
    }

    public weak var delegate: SignificantTimePassedDetectorDelegate?

    public init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.significantTimeChanged(_:)),
                                               name: UIApplication.significantTimeChangeNotification,
                                               object: nil)
    }

    @objc private func significantTimeChanged(_ notification: Any) {
        self.fire(with: .STCNotification)
    }

    private func fire(with reason: SignificantTimePassedDetector.Reason) {
        self.delegate?.significantTimeDidPass(with: reason, detector: self)
    }
}
