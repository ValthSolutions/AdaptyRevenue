//
//  RevenueErrorProtocol.swift
//  AdaptyRevenue
//
//  Created by Dmytro Akulinin on 15.08.2025.
//

import Foundation

public enum RevenueError: Error, Sendable {
    case network
    case notActivated            
    case invalidProductID
    case paywallNotFound
    case profileUnavailable
    case purchaseCancelled
    case purchasePending
    case purchaseVerificationFailed
    case purchaseNotAllowed
    case restoreFailed
    case identifyFailed
    case attributionFailed
    case mapping
    case notEligible
    case unknown(underlying: String)
}
