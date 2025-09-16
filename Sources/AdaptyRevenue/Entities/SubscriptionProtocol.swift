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
    var isInGraceOrRetry: Bool { get }
    var isFamilyPlan: Bool { get }
    var lastPaymentDate: Date? { get }
    var nextRenewalDate: Date? { get }
}
