//
//  PurchaseEventProtocol.swift
//  AdaptyRevenue
//
//  Created by Dmytro Akulinin on 15.08.2025.
//

public protocol AdaptyServiceEvent: Sendable {
    var kind: AdaptyServiceEventKind { get }
}

public struct PurchaseEvent: AdaptyServiceEvent {
    public var kind: AdaptyServiceEventKind
    
    public init(kind: AdaptyServiceEventKind) {
        self.kind = kind
    }
}
