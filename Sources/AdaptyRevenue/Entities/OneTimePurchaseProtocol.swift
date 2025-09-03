//
//  OneTimePurchaseProtocol.swift
//  AdaptyRevenue
//
//  Created by Dmytro Akulinin on 15.08.2025.
//

import Foundation

public protocol OneTimePurchaseProtocol: Sendable {
    var id: String { get }
    var dates: [Date] { get }       
    var lastDate: Date? { get }
    var count: Int { get }

    var isConsumable: Bool? { get }
    var isRefunded: Bool { get }
    var isSandboxOnly: Bool { get }
    var transactions: [OneTimeTransaction]? { get }
}


public struct OneTimePurchaseModel: OneTimePurchaseProtocol, Sendable {
    public var id: String
    
    public var dates: [Date]
    
    public var lastDate: Date?
    
    public var count: Int
    
    public var isConsumable: Bool?
    
    public var isRefunded: Bool
    
    public var isSandboxOnly: Bool
    
    public var transactions: [OneTimeTransaction]?
}

public struct OneTimeTransaction: Sendable {
    public let purchaseId: String
    public let vendorTransactionId: String?
    public let purchasedAt: Date
    public let isRefund: Bool
    public let isSandbox: Bool
    public let isConsumable: Bool
}
