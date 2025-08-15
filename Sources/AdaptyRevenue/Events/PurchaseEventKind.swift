//
//  PurchaseEventKind.swift
//  AdaptyRevenue
//
//  Created by Dmytro Akulinin on 15.08.2025.
//

import Foundation

public enum PurchaseEventKind: Sendable {
    case purchased(productID: String, transactionID: String?)
    case restored
    case profileUpdated
}
