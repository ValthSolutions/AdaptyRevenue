//
//  ProductProtocol.swift
//  AdaptyRevenue
//
//  Created by Dmytro Akulinin on 15.08.2025.
//

import Foundation
import Adapty
import Adapty

public protocol ProductProtocol: Sendable {
    var id: String { get }
    var displayName: String { get }
    var price: Decimal { get }
    var currencyCode: String? { get }
    var localizedPrice: String? { get }
    var currencySymbol: String? { get }
    var regionCode: String? { get }

    var isSubscription: Bool { get }
    var subscriptionPeriod: AdaptySubscriptionPeriod? { get }
    var subscriptionGroupIdentifier: String? { get }
    var trialAvailable: Bool { get }
    var introOfferType: AdaptySubscriptionOffer.OfferType? { get }

    var isFamilyPlan: Bool { get }      
    var hasSK2: Bool { get }

    var paywallName: String { get }
    var paywallProductIndex: Int { get }
    var adaptyProductId: String { get }

    var native: AdaptyPaywallProduct { get }
}

public struct ProductModel: ProductProtocol {
    public let id: String
    public let displayName: String
    public let price: Decimal
    public let currencyCode: String?
    public let localizedPrice: String?
    public let currencySymbol: String?
    public let regionCode: String?

    public let isSubscription: Bool
    public let subscriptionPeriod: AdaptySubscriptionPeriod?
    public let subscriptionGroupIdentifier: String?
    public let trialAvailable: Bool
    public let introOfferType: AdaptySubscriptionOffer.OfferType?

    public let isFamilyPlan: Bool
    public let hasSK2: Bool

    public let paywallName: String
    public let paywallProductIndex: Int
    public let adaptyProductId: String

    public let native: AdaptyPaywallProduct
}
