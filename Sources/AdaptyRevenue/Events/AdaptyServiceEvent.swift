//
//  PurchaseEventProtocol.swift
//  AdaptyRevenue
//
//  Created by Dmytro Akulinin on 15.08.2025.
//

public protocol IAdaptyServiceEvent: Sendable {
    var kind: AdaptyServiceEventKind { get }
}

public struct AdaptyServiceEvent: IAdaptyServiceEvent {
    public var kind: AdaptyServiceEventKind
    
    public init(kind: AdaptyServiceEventKind) {
        self.kind = kind
    }
}
