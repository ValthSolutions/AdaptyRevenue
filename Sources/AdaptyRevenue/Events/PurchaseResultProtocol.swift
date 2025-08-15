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
