//
//  AdaptyRevenueService.swift
//  AdaptyRevenue
//
//  Created by Dmytro Akulinin on 15.08.2025.
//

import Adapty
import Foundation
import Combine
import StoreKit

public final class AdaptyRevenueService: AdaptyRevenueServiceProtocol, @unchecked Sendable {

    public var eventsPublisher: AnyPublisher<any IAdaptyServiceEvent, Never> {
        eventsSubject.eraseToAnyPublisher()
    }

    private let eventsSubject = PassthroughSubject<any IAdaptyServiceEvent, Never>()
    private let eventContinuations = EventContinuations()

    private var config: AdaptyRevenueConfigProviding?

    private actor EventContinuations {

        private var storage: [UUID: AsyncStream<any IAdaptyServiceEvent>.Continuation] = [:]

        func add(_ continuation: AsyncStream<any IAdaptyServiceEvent>.Continuation) -> UUID {
            let id = UUID()
            storage[id] = continuation
            return id
        }

        func remove(_ id: UUID) {
            storage[id] = nil
        }

        func yield(_ event: any IAdaptyServiceEvent) {
            for continuation in storage.values {
                continuation.yield(event)
            }
        }
    }

    public init() {}

    // Lifecycle
    public func start(with config: AdaptyRevenueConfigProviding) async throws {
        self.config = config
        Adapty.delegate = self
        Adapty.logLevel = config.logLevel
        let adaptyToken = config.adaptyApiKey
        let userId = config.userId

        let configurationBuilder = AdaptyConfiguration
            .builder(withAPIKey: adaptyToken)
            .with(observerMode: config.isObserverMode)
            .with(customerUserId: userId)
            .with(idfaCollectionDisabled: false)

        try await Adapty.activate(with: configurationBuilder.build())
    }

    public func shutdown() async {
        Adapty.delegate = nil
        self.config = nil
    }

    // Events
    private func emit(_ event: any IAdaptyServiceEvent) {
        eventsSubject.send(event)
        Task {
            await eventContinuations.yield(event)
        }
    }

    public func eventsStream() -> AsyncStream<any IAdaptyServiceEvent> {
        AsyncStream { continuation in
            Task {
                let id = await eventContinuations.add(continuation)
                continuation.onTermination = { [weak self] _ in
                    guard let self else { return }
                    Task { await self.eventContinuations.remove(id) }
                }
            }
        }
    }

    // Products
    public func fetchAllProducts() async throws -> [any ProductProtocol] {
        guard let config else {
            throw RevenueError.mapping
        }

        var seenProductIDs = Set<String>()
        var aggregatedProducts: [any ProductProtocol] = []

        for placementId in config.paywallPlacements {
            do {
                let paywall = try await Adapty.getPaywall(placementId: placementId)
                let paywallProducts = try await Adapty.getPaywallProducts(paywall: paywall)
                for paywallProduct in paywallProducts {
                    let productID = paywallProduct.vendorProductId
                    if seenProductIDs.insert(productID).inserted {
                        aggregatedProducts.append(map(paywallProduct))
                    }
                }
            } catch {
                throw RevenueError.mapping
            }
        }

        return aggregatedProducts
    }

    public func fetchProducts(forPaywall id: String) async throws -> [any ProductProtocol] {
        let paywall = try await Adapty.getPaywall(placementId: id)
        let paywallProducts = try await Adapty.getPaywallProducts(paywall: paywall)
        return paywallProducts.map { map($0) }
    }

    // Profile / Status
    public func isSubscriber(level: String) async -> Bool {
        do {
            let profile = try await Adapty.getProfile()
            return profile.accessLevels[level]?.isActive == true
        } catch {
            return false
        }
    }

    public func currentSubscription(level: String) async -> (any SubscriptionProtocol)? {
        do {
            let profile = try await Adapty.getProfile()
            guard let info = profile.accessLevels[level], info.isActive else { return nil }
            return SubscriptionModel(
                level: info.id,
                isActive: true,
                isInGracePeriod: info.isInGracePeriod,
                isInRetryPeriod: info.billingIssueDetectedAt != nil,
                lastPaymentDate: info.renewedAt,
                nextRenewalDate: info.expiresAt
            )
        } catch {
            return nil
        }
    }

    // Flags & Dates
    public func isInGracePeriod(level: String) async -> Bool {
        do {
            let profile = try await Adapty.getProfile()
            return profile.accessLevels[level]?.isInGracePeriod == true
        } catch { return false }
    }

    public func isInRetryPeriod(level: String) async -> Bool {
        do {
            let profile = try await Adapty.getProfile()
            return profile.accessLevels[level]?.billingIssueDetectedAt != nil
        } catch { return false }
    }

    public func lastPaymentDate(level: String) async -> Date? {
        do {
            let profile = try await Adapty.getProfile()
            return profile.accessLevels[level]?.renewedAt
        } catch {
            return nil
        }
    }

    public func nextRenewalDate(level: String) async -> Date? {
        do {
            let profile = try await Adapty.getProfile()
            return profile.accessLevels[level]?.expiresAt
        } catch {
            return nil
        }
    }

    // Eligibility & History
    public func isEligibleForTrial(productID: String) async -> Bool {
        let alreadyPurchased = await hasPurchased(productID)
        return !alreadyPurchased
    }

    public func hasPurchased(_ productID: String) async -> Bool {
        do {
            let profile = try await Adapty.getProfile()
            if profile.accessLevels.values.contains(where: { $0.vendorProductId == productID }) { return true }
            if let entries = profile.nonSubscriptions[productID], !entries.isEmpty { return true }
            return false
        } catch {
            return false
        }
    }

    public func purchasedProductIDs() async -> Set<String> {
        do {
            let profile = try await Adapty.getProfile()
            var ids = Set<String>()
            ids.formUnion(profile.accessLevels.values.map { $0.vendorProductId })
            ids.formUnion(profile.nonSubscriptions.keys)
            return ids
        } catch {
            return []
        }
    }

    public func oneTimePurchases() async -> [String : any OneTimePurchaseProtocol] {
        do {
            let profile = try await Adapty.getProfile()
            var result: [String: any OneTimePurchaseProtocol] = [:]

            for (productID, entries) in profile.nonSubscriptions {
                let transactions = entries.map {
                    OneTimeTransaction(
                        purchaseId: $0.purchaseId,
                        vendorTransactionId: $0.vendorTransactionId,
                        purchasedAt: $0.purchasedAt,
                        isRefund: $0.isRefund,
                        isSandbox: $0.isSandbox,
                        isConsumable: $0.isConsumable
                    )
                }

                let dates = transactions.map(\.purchasedAt).sorted()
                let isConsumable: Bool? = {
                    let allConsumable = transactions.allSatisfy { $0.isConsumable }
                    let allNonConsumable = transactions.allSatisfy { !$0.isConsumable }
                    if allConsumable { return true }
                    if allNonConsumable { return false }
                    return nil
                }()

                let model = OneTimePurchaseModel(
                    id: productID,
                    dates: dates,
                    lastDate: dates.last,
                    count: dates.count,
                    isConsumable: isConsumable,
                    isRefunded: transactions.contains { $0.isRefund },
                    isSandboxOnly: transactions.allSatisfy { $0.isSandbox },
                    transactions: transactions
                )

                result[productID] = model
            }

            return result
        } catch {
            return [:]
        }
    }

    // Actions
    public func purchase(productID: String) async throws -> any PurchaseResultProtocol {
        emit(AdaptyServiceEvent(kind: .purchaseStarted(productID: productID)))

        let paywallProduct = try await resolvePaywallProduct(for: productID)

        if config?.isObserverMode == true {
            guard let storeKitProduct = paywallProduct.sk2Product else {
                emit(AdaptyServiceEvent(kind: .purchaseFailed(productID: productID, error: "SK2 product is nil")))
                return PurchaseResultModel(isSuccess: false, productID: productID, transactionID: nil, errorDescription: "SK2 product is nil")
            }

            let result = try await storeKitProduct.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    let txId = String(transaction.id)
                    emit(AdaptyServiceEvent(kind: .purchaseSucceeded(
                        productID: productID,
                        transactionID: txId,
                        price: paywallProduct.price,
                        currency: paywallProduct.currencyCode ?? paywallProduct.priceLocale.currency?.identifier ?? ""
                    )))
                    await transaction.finish()
                    return PurchaseResultModel(isSuccess: true, productID: productID, transactionID: txId, errorDescription: nil)

                case .unverified(let transaction, let error):
                    let txId = String(transaction.id)
                    emit(AdaptyServiceEvent(kind: .purchaseFailed(productID: productID, error: error.localizedDescription)))
                    await transaction.finish()
                    return PurchaseResultModel(isSuccess: false, productID: productID, transactionID: txId, errorDescription: error.localizedDescription)
                }

            case .userCancelled:
                emit(AdaptyServiceEvent(kind: .purchaseFailed(productID: productID, error: "cancelled")))
                return PurchaseResultModel(isSuccess: false, productID: productID, transactionID: nil, errorDescription: "cancelled")

            case .pending:
                emit(AdaptyServiceEvent(kind: .purchaseFailed(productID: productID, error: "pending")))
                return PurchaseResultModel(isSuccess: false, productID: productID, transactionID: nil, errorDescription: "pending")

            @unknown default:
                emit(AdaptyServiceEvent(kind: .purchaseFailed(productID: productID, error: "unknown")))
                return PurchaseResultModel(isSuccess: false, productID: productID, transactionID: nil, errorDescription: "unknown")
            }
        } else {
            let adaptyResult = try await Adapty.makePurchase(product: paywallProduct)

            if adaptyResult.isPurchaseCancelled {
                emit(AdaptyServiceEvent(kind: .purchaseFailed(productID: productID, error: "cancelled")))
                return PurchaseResultModel(isSuccess: false, productID: productID, transactionID: nil, errorDescription: "cancelled")
            }

            if adaptyResult.isPurchasePending {
                emit(AdaptyServiceEvent(kind: .purchaseFailed(productID: productID, error: "pending")))
                return PurchaseResultModel(isSuccess: false, productID: productID, transactionID: nil, errorDescription: "pending")
            }

            if adaptyResult.isPurchaseSuccess {
                let transactionID: String? = {
                    if let t = adaptyResult.sk2Transaction { return String(t.id) }
                    if let t = adaptyResult.sk1Transaction { return t.transactionIdentifier }
                    if #available(iOS 15.0, *) { return adaptyResult.jwsTransaction }
                    return nil
                }()

                emit(AdaptyServiceEvent(kind: .purchaseSucceeded(
                    productID: productID,
                    transactionID: transactionID,
                    price: paywallProduct.price,
                    currency: paywallProduct.currencyCode ?? paywallProduct.priceLocale.currency?.identifier ?? ""
                )))

                return PurchaseResultModel(isSuccess: true, productID: productID, transactionID: transactionID, errorDescription: nil)
            }

            emit(AdaptyServiceEvent(kind: .purchaseFailed(productID: productID, error: "unknown")))
            return PurchaseResultModel(isSuccess: false, productID: productID, transactionID: nil, errorDescription: "unknown")
        }
    }

    public func restorePurchases() async throws {
        let _ = try await Adapty.restorePurchases()
        emit(AdaptyServiceEvent(kind: .restored))
    }

    public func setCustomerUserId(_ id: String) async throws {
        try await Adapty.identify(id)
    }

    public func logout() async throws {
        try await Adapty.logout()
    }

    public func updateAttribution(_ data: [AnyHashable : Any], from source: String) async throws {
        try await Adapty.updateAttribution(data, source: source)
    }

    private func resolvePaywallProduct(for productID: String) async throws -> AdaptyPaywallProduct {
        guard let config else { throw RevenueError.mapping }
        for placementId in config.paywallPlacements {
            do {
                let paywall = try await Adapty.getPaywall(placementId: placementId)
                let products = try await Adapty.getPaywallProducts(paywall: paywall)
                if let match = products.first(where: { $0.vendorProductId == productID }) {
                    return match
                }
            } catch {
                continue
            }
        }
        throw RevenueError.invalidProductID
    }
}

extension AdaptyRevenueService: AdaptyDelegate {
    public func didLoadLatestProfile(_ profile: AdaptyProfile) {
        emit(AdaptyServiceEvent(kind: .profileUpdated))
    }
}

extension AdaptyRevenueService {
    private func map(_ product: AdaptyPaywallProduct) -> ProductModel {
        return ProductModel(
            id: product.vendorProductId,
            displayName: product.localizedTitle,
            price: product.price,
            currencyCode: product.currencyCode ?? product.priceLocale.currency?.identifier ?? nil,
            localizedPrice: product.localizedPrice,
            currencySymbol: product.currencySymbol,
            regionCode: product.regionCode,

            isSubscription: product.subscriptionPeriod != nil,
            subscriptionPeriod: product.subscriptionPeriod,
            subscriptionGroupIdentifier: product.subscriptionGroupIdentifier,
            trialAvailable: product.subscriptionOffer != nil,
            introOfferType: product.subscriptionOffer?.offerType,

            isFamilyPlan: product.isFamilyShareable,
            hasSK2: product.sk2Product != nil,
            paywallName: product.paywallName,
            paywallProductIndex: product.paywallProductIndex,
            adaptyProductId: product.adaptyProductId,

            native: product
        )
    }
}
