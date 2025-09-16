//
//  ProductProtocol.swift
//  AdaptyRevenue
//
//  Created by Dmytro Akulinin on 15.08.2025.
//

import Foundation

public protocol ProductProtocol: Sendable {
    var id: String { get }
    var displayName: String { get }
    var price: Decimal { get }
    var currencyCode: String { get }
    var isSubscription: Bool { get }
    var level: String? { get }
    var trialAvailable: Bool { get }
    // To dicuss: can be adapty native product type (AdaptyPaywallProduct) or can be handled on app level
    var native: Any? { get }
}
