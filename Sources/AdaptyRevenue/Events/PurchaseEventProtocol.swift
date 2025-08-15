//
//  PurchaseEventProtocol.swift
//  AdaptyRevenue
//
//  Created by Dmytro Akulinin on 15.08.2025.
//

public protocol PurchaseEventProtocol: Sendable {
    var kind: PurchaseEventKind { get }
}

public struct PurchaseEvent: PurchaseEventProtocol {
    public var kind: PurchaseEventKind
    
    public init(kind: PurchaseEventKind) {
        self.kind = kind
    }
}
