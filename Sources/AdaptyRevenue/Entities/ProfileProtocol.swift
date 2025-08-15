//
//  ProfileProtocol.swift
//  AdaptyRevenue
//
//  Created by Dmytro Akulinin on 15.08.2025.
//

public protocol ProfileProtocol: Sendable {
    var subscriptions: [any SubscriptionProtocol] { get }
    var purchasedProductIDs: Set<String> { get }
}
