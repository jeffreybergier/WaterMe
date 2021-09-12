//
//  Result+Convenience.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 2019/10/27.
//  Copyright © 2019 Saturday Apps.
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

extension Result {
    public var error: Failure? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }

    public var value: Success? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }

    /// Returns a new Result by mapping `Success`es’ values using `success`, and by mapping `Failure`'s values using `failure`.
    /// Slightly Modified from Antitypical Code:
    /// https://github.com/antitypical/Result/blob/c0838342cedfefc25f6dd4f95344d376bed582c7/Result/ResultProtocol.swift#L64
    public func bimap<Success2, Failure2>(success: (Success) -> Success2, failure: (Failure) -> Failure2) -> Result<Success2, Failure2> {
        switch self {
        case let .success(value): return .success(success(value))
        case let .failure(error): return .failure(failure(error))
        }
    }
    
    
    /// Lazily chains multiple result closures.
    /// On error, stops and returns error.
    /// On success, continues and returns last success.
    /// - Parameter next: Closure to execute on success, passing in result of last operation.
    /// - Returns: Last success or first failure.
    public func reduce<NewSuccess>(_ next: (Success) -> Result<NewSuccess, Failure>) -> Result<NewSuccess, Failure> {
        switch self {
        case .success(let value): return next(value)
        case .failure(let error): return .failure(error)
        }
    }
}
