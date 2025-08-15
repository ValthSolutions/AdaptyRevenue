//
//  RevenueErrorProtocol.swift
//  AdaptyRevenue
//
//  Created by Dmytro Akulinin on 15.08.2025.
//

public protocol RevenueErrorProtocol: Error, Sendable {
    var message: String { get }
}

public struct RevenueNotImplementedError: RevenueErrorProtocol {
    public let message: String
    public init(_ message: String = "Not implemented") {
        self.message = message
    }
}
