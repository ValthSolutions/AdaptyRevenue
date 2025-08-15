//
//  AdaptyRevenueServiceProtocol.swift
//  AdaptyRevenue
//
//  Created by Dmytro Akulinin on 15.08.2025.
//

import Combine
import Foundation

public protocol AdaptyRevenueServiceProtocol: Sendable {
    // Lifecycle
    func start(with config: AdaptyRevenueConfigProviding) async throws
    func shutdown() async

    // Events (Global events like profile has changed)
    var eventsPublisher: AnyPublisher<any PurchaseEventProtocol, Never> { get }
    func eventsStream() -> AsyncStream<any PurchaseEventProtocol>

    // Products
    func fetchAllProducts() async throws -> [any ProductProtocol]
    func fetchProducts(forPaywall id: String) async throws -> [any ProductProtocol]

    // Profile / Status
    @discardableResult
    func refreshProfile() async throws -> any ProfileProtocol

    func isSubscriber(level: String?) async -> Bool
    func currentSubscription(level: String?) async -> (any SubscriptionProtocol)?

    // Flags & Dates
    func isInRetryPeriod(level: String?) async -> Bool
    func isFamilyPlan(level: String?) async -> Bool
    func lastPaymentDate(level: String?) async -> Date?
    func nextRenewalDate(level: String?) async -> Date?

    // Eligibility & History
    func isEligibleForTrial(productID: String) async -> Bool
    func hasPurchased(_ productID: String) async -> Bool
    func purchasedProductIDs() async -> Set<String>
    func oneTimePurchases() async -> [String: any OneTimePurchaseProtocol]

    // Actions
    func purchase(productID: String) async throws -> any PurchaseResultProtocol
    func restorePurchases() async throws
}
