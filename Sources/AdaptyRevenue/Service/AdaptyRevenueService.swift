//
//  AdaptyRevenueService.swift
//  AdaptyRevenue
//
//  Created by Dmytro Akulinin on 15.08.2025.
//

import Adapty
import Foundation
import Combine

public final class AdaptyRevenueService: AdaptyRevenueServiceProtocol, @unchecked Sendable {
    private let eventsSubject = PassthroughSubject<any AdaptyServiceEvent, Never>()
    public var eventsPublisher: AnyPublisher<any AdaptyServiceEvent, Never> {
        eventsSubject.eraseToAnyPublisher()
    }
    
    public init() {}

    // Lifecycle
    public func start(with config: AdaptyRevenueConfigProviding) async throws {
        fatalError("Not implemented")
    }

    public func shutdown() async {
        fatalError("Not implemented")
    }

    // Events
    public func eventsStream() -> AsyncStream<any AdaptyServiceEvent> {
        fatalError("Not implemented")
    }

    // Products
    public func fetchAllProducts() async throws -> [any ProductProtocol] {
        fatalError("Not implemented")
    }

    public func fetchProducts(forPaywall id: String) async throws -> [any ProductProtocol] {
        fatalError("Not implemented")
    }

    // Profile / Status
    @discardableResult
    public func refreshProfile() async throws -> any ProfileProtocol {
        fatalError("Not implemented")
    }

    public func isSubscriber(level: String?) async -> Bool {
        fatalError("Not implemented")
    }

    public func currentSubscription(level: String?) async -> (any SubscriptionProtocol)? {
        fatalError("Not implemented")
    }

    // Flags & Dates
    public func isInRetryPeriod(level: String?) async -> Bool {
        fatalError("Not implemented")
    }

    public func isFamilyPlan(level: String?) async -> Bool {
        fatalError("Not implemented")
    }

    public func lastPaymentDate(level: String?) async -> Date? {
        fatalError("Not implemented")
    }

    public func nextRenewalDate(level: String?) async -> Date? {
        fatalError("Not implemented")
    }

    // Eligibility & History
    public func isEligibleForTrial(productID: String) async -> Bool {
        fatalError("Not implemented")
    }

    public func hasPurchased(_ productID: String) async -> Bool {
        fatalError("Not implemented")
    }

    public func purchasedProductIDs() async -> Set<String> {
        fatalError("Not implemented")
    }

    public func oneTimePurchases() async -> [String : any OneTimePurchaseProtocol] {
        fatalError("Not implemented")
    }

    // Actions
    public func purchase(productID: String) async throws -> any PurchaseResultProtocol {
        fatalError("Not implemented")
    }

    public func restorePurchases() async throws {
        fatalError("Not implemented")
    }

    public func setCustomerUserId(_ id: String?) async {
        fatalError("Not implemented")
    }

    public func logout() async {
        fatalError("Not implemented")
    }

    public func updateAttribution(_ data: [AnyHashable : Any], from source: String) async {
        fatalError("Not implemented")
    }
}

extension AdaptyRevenueService: AdaptyDelegate {
    public func didLoadLatestProfile(_ profile: AdaptyProfile) {
        eventsSubject.send(PurchaseEvent.init(kind: .profileUpdated))
    }
}
