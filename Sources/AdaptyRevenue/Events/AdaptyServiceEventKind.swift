//
//  PurchaseEventKind.swift
//  AdaptyRevenue
//
//  Created by Dmytro Akulinin on 15.08.2025.
//

import Foundation

// TODO: Params shoud be extended during implementation
public enum AdaptyServiceEventKind: Sendable {
    // purchase lifecycle
    case purchaseStarted(productID: String)
    case purchaseSucceeded(productID: String, transactionID: String?, price: Decimal?, currency: String?)
    case purchaseFailed(productID: String, error: String)

    // other
    case restored
    case profileUpdated
}
