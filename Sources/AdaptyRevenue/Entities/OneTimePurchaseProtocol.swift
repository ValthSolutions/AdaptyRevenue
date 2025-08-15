//
//  OneTimePurchaseProtocol.swift
//  AdaptyRevenue
//
//  Created by Dmytro Akulinin on 15.08.2025.
//

import Foundation

public protocol OneTimePurchaseProtocol: Sendable {
    var productID: String { get }
    var purchaseDate: Date { get }
    var transactionID: String? { get }
}
