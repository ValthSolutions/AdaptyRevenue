//
//  RevenueErrorProtocol.swift
//  AdaptyRevenue
//
//  Created by Dmytro Akulinin on 15.08.2025.
//

import Foundation

public enum RevenueError: Error, Sendable {
    case network
    case purchaseCancelled
    case notEligible
    case invalidProductID
    case mapping
    case unknown(underlying: String)
}
