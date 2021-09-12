//
//  ZStackView.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 2021/06/27.
//  Copyright © 2021 Saturday Apps. All rights reserved.
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

public class ZStackView: UIView {
    
    public enum Error: Swift.Error {
        case givenViewNotManaged
    }
    
    public private(set) var arrangedSubviews: [UIView] = []
    public weak var animationDelegate: ZStackViewAnimationDelegate?
    
    public func addArrangedSubview(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        self.addConstraints([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        self.bringSubviewToFront(view)
        self.arrangedSubviews = [view] + self.arrangedSubviews
    }
    
    @discardableResult
    public func removeArrangedSubview(_ view: UIView) -> Result<Void, Error> {
        let beforeCount = self.arrangedSubviews.count
        self.arrangedSubviews.removeAll(where: { $0 === view })
        let afterCount = self.arrangedSubviews.count
        guard beforeCount - afterCount == 1 else { return .failure(.givenViewNotManaged) }
        view.removeFromSuperview()
        return .success(())
    }
    
    @discardableResult
    public func bringArrangedSubviewToFront(_ view: UIView) -> Result<Void, Error> {
        guard let index = self.arrangedSubviews.firstIndex(of: view) else { return .failure(.givenViewNotManaged) }
        self.arrangedSubviews.remove(at: index)
        self.arrangedSubviews = [view] + self.arrangedSubviews
        self.arrangedSubviews.enumerated().reversed().forEach { index, view in
            self.bringSubviewToFront(view)
        }
        self.animationDelegate?.didReorderArrangedSubviews(self)
        return .success(())
    }
    
}

public protocol ZStackViewAnimationDelegate: AnyObject {
    func didReorderArrangedSubviews(_: ZStackView)
}
