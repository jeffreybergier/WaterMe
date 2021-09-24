//
//  PurchaseController.swift
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

import StoreKit

public class PurchaseController {

    private let purchaser = Purchaser()

    public var transactionsInFlightUpdated: (() -> Void)?
    private var transactionsInFlight: [InFlightTransaction] = []

    public init?() {
        guard SKPaymentQueue.canMakePayments() else { return nil }
        self.purchaser.transactionsUpdated = { [weak self] inFlights in
            self?.transactionsInFlight += inFlights
            self?.transactionsInFlightUpdated?()
        }
    }

    public func nextTransactionForPresentingToUser() -> InFlightTransaction? {
        return self.transactionsInFlight.popLast()
    }

    public func buy(product: SKProduct) {
        self.purchaser.buy(product: product)
    }

    public func finish(inFlight: InFlightTransaction) {
        self.purchaser.finish(inFlight: inFlight)
    }

    public func fetchTipJarProducts(completion: @escaping (TipJarProducts?) -> Void) {
        let requester = TipJarProductRequester()
        requester.fetchTipJarProducts { result in
            _ = requester // capture the requester here so its not released and deallocated mid-flight
            completion(result)
        }
    }
}

internal class Purchaser: NSObject, SKPaymentTransactionObserver {

    internal var transactionsUpdated: (([InFlightTransaction]) -> Void)?
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    internal func buy(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    internal func finish(inFlight: InFlightTransaction) {
        SKPaymentQueue.default().finishTransaction(inFlight.transaction)
    }

    private func finish(transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    internal func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        let (inFlight, _, readyToBeFinished) = InFlightTransaction.process(transactions: transactions)
        readyToBeFinished.forEach({ self.finish(transaction: $0) })
        self.transactionsUpdated?(inFlight)
    }

    deinit {
        SKPaymentQueue.default().remove(self)
    }
}
