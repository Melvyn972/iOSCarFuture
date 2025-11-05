//
//  VehicleToBuy.swift
//  CarFuture
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//
import Foundation
import CarFuturePackage

struct VehicleToBuy: Identifiable, Codable, Hashable {
    let id: UUID
    var type: VehicleType
    var name: String
    var listingURL: String?
    var price: Double?
    var photos: [PhotoAsset]
    var notes: String
    var characteristics: Characteristics
    var plannedParts: [PartItem]

    init(
        id: UUID = UUID(),
        type: VehicleType,
        name: String,
        listingURL: String? = nil,
        price: Double? = nil,
        photos: [PhotoAsset] = [],
        notes: String = "",
        characteristics: Characteristics = .init(),
        plannedParts: [PartItem] = []
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.listingURL = listingURL
        self.price = price
        self.photos = photos
        self.notes = notes
        self.characteristics = characteristics
        self.plannedParts = plannedParts
    }

    var plannedTotal: Double { plannedParts.totalCost + (price ?? 0) }
}
