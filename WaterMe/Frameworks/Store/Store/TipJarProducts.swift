//
//  TipJarProducts.swift
//  WaterMeStore
//
//  Created by Jeffrey Bergier on 13/1/18.
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

public struct TipJarProducts {

    public let small: SKProduct
    public let medium: SKProduct
    public let large: SKProduct

    internal init?(products: [SKProduct]) {
        guard let keys = PrivateKeys.kConsumableTipJar else { return nil }
        let _small = products.first(where: { $0.productIdentifier == keys.small })
        let _medium = products.first(where: { $0.productIdentifier == keys.medium })
        let _large = products.first(where: { $0.productIdentifier == keys.large })
        guard let small = _small, let medium = _medium, let large = _large else { return nil }
        self.small = small
        self.medium = medium
        self.large = large
    }
}

internal class TipJarProductRequester: NSObject, SKProductsRequestDelegate {

    private var completion: ((TipJarProducts?) -> Void)?

    internal func fetchTipJarProducts(completion: @escaping (TipJarProducts?) -> Void) {
        guard let keys = PrivateKeys.kConsumableTipJar else {
            completion(nil)
            return
        }

        self.completion = completion
        let request = SKProductsRequest(productIdentifiers: [
            keys.small,
            keys.medium,
            keys.large,
            ])
        request.delegate = self
        request.start()
    }

    internal func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = TipJarProducts(products: response.products)
        DispatchQueue.main.async {
            if let products = products {
                self.completion?(products)
            } else {
                self.completion?(nil)
            }
            self.completion = nil // nil the completion handler since it captures self. It creates a retain cycle.
        }
    }
}
