//
//  PartItem.swift
//  CarFuture
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//
import Foundation

struct PartItem: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var url: String?
    var price: Double

    init(id: UUID = UUID(), name: String, url: String? = nil, price: Double) {
        self.id = id
        self.name = name
        self.url = url
        self.price = price
    }
}

extension Sequence where Element == PartItem {
    var totalCost: Double { reduce(0) { $0 + $1.price } }
}
