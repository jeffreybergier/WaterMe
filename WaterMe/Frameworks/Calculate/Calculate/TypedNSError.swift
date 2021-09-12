//
//  TypedError.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on R 3/07/11.
//  Copyright © 2021 Saturday Apps.
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

import Foundation

public protocol ErrorInitable {
    init(_ error: Swift.Error)
}

open class TypedNSError<T: ErrorInitable>: ErrorInitable, CustomNSError {
    
    open class var errorDomain: String { "com.saturdayapps.WaterMe.InvalidDomain" }
    open var errorCode: Int { self.untyped.code }
    open var errorUserInfo: [String : Any] {
        var userInfo = self.errorUserInfo
        userInfo["JSBOriginalErrorDomainKey"] = self.untyped.domain
        return userInfo
    }
    
    public let typed: T
    public let untyped: NSError
    
    public required init(_ error: Error) {
        self.untyped = error as NSError
        self.typed = .init(error)
    }
}
