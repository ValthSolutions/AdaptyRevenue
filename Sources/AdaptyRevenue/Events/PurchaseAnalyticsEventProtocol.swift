//
//  PurchaseAnalyticsEventProtocol.swift
//  AdaptyRevenue
//
//  Created by Dmytro Akulinin on 15.08.2025.
//

import Foundation

public protocol PurchaseAnalyticsEventProtocol: Sendable {
    var kind: PurchaseAnalyticsEventKind { get }
}

public enum PurchaseAnalyticsEventKind: Sendable {
    case purchaseStarted(productID: String)
    case purchaseSucceeded(productID: String, transactionID: String?, price: Decimal?, currency: String?)
    case purchaseFailed(productID: String, error: String)
    case restored
    case profileChanged(isSubscriber: Bool, level: String?)
}
