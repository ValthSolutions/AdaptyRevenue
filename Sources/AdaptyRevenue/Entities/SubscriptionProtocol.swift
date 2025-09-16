//
//  SubscriptionProtocol.swift
//  AdaptyRevenue
//
//  Created by Dmytro Akulinin on 15.08.2025.
//

import Foundation

public protocol SubscriptionProtocol: Sendable {
    var level: String { get }
    var isActive: Bool { get }
    var isInGracePeriod: Bool { get }
    var isInRetryPeriod: Bool { get }
    var lastPaymentDate: Date? { get }
    var nextRenewalDate: Date? { get }
}

public struct SubscriptionModel: SubscriptionProtocol {
    public let level: String
    public let isActive: Bool
    public let isInGracePeriod: Bool
    public let isInRetryPeriod: Bool
    public let lastPaymentDate: Date?
    public let nextRenewalDate: Date?
}
