//
//  AdaptyRevenueConfigProviding.swift
//  AdaptyRevenue
//
//  Created by Dmytro Akulinin on 15.08.2025.
//

import Foundation

public protocol AdaptyRevenueConfigProviding: Sendable {
    var adaptyApiKey: String { get }
    var environment: String { get }
    var levels: [String: [String]] { get }
    var analyticsCallback: ((any PurchaseAnalyticsEventProtocol) -> Void)? { get }
    var oneTimePurchasesCallback: (([String: any OneTimePurchaseProtocol]) -> Void)? { get }
    var logCallback: ((String) -> Void)? { get }
}
