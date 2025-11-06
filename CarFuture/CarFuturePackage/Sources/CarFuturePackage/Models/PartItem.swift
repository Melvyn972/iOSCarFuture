//
//  PartItem.swift
//  CarFuture
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//
import Foundation

public struct PartItem: Identifiable, Codable, Hashable {
    public let id: UUID
    public var name: String
    public var url: String?
    public var price: Double

    public init(id: UUID = UUID(), name: String, url: String? = nil, price: Double) {
        self.id = id
        self.name = name
        self.url = url
        self.price = price
    }
}

public extension Sequence where Element == PartItem {
    var totalCost: Double { reduce(0) { $0 + $1.price } }
}
