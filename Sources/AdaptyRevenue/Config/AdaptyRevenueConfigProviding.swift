//
//  AdaptyRevenueConfigProviding.swift
//  AdaptyRevenue
//
//  Created by Dmytro Akulinin on 15.08.2025.
//

import Foundation
import Adapty

public protocol AdaptyRevenueConfigProviding: Sendable {
    var adaptyApiKey: String { get }
    var environment: Environment { get }
    var logCallback: ((String) -> Void)? { get }
    var isObserverMode: Bool { get }
    var logLevel: AdaptyLog.Level { get }
    var userId: String { get }
    var paywallPlacements: [String] { get }
}

public enum Environment: String, Sendable {
    case production, development, staging
}
