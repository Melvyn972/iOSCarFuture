//
//  VehicleToBuy.swift
//  CarFuture
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//
import Foundation

public struct VehicleToBuy: Identifiable, Codable, Hashable {
    public let id: UUID
    public var type: VehicleType
    public var name: String
    public var listingURL: String?
    public var price: Double?
    public var photos: [PhotoAssetCarFuture]
    public var notes: String
    public var characteristics: Characteristics
    public var plannedParts: [PartItem]

    public init(
        id: UUID = UUID(),
        type: VehicleType,
        name: String,
        listingURL: String? = nil,
        price: Double? = nil,
        photos: [PhotoAssetCarFuture] = [],
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

    public var plannedTotal: Double { plannedParts.totalCost + (price ?? 0) }
}
