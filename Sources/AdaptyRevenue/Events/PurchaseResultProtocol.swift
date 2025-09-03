//
//  PurchaseResultProtocol.swift
//  AdaptyRevenue
//
//  Created by Dmytro Akulinin on 15.08.2025.
//


public protocol PurchaseResultProtocol: Sendable {
    var isSuccess: Bool { get }
    var productID: String? { get }
    var transactionID: String? { get }
    var errorDescription: String? { get }
}

public struct PurchaseResultModel: PurchaseResultProtocol {
    public let isSuccess: Bool
    public let productID: String?
    public let transactionID: String?
    public let errorDescription: String?
}
