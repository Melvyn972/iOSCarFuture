//
//  Vehicle.swift
//  CarFuture
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//
import Foundation

public struct Vehicle: Identifiable, Codable, Hashable {
    public let id: UUID
    public var type: VehicleType
    public var name: String
    public var photos: [PhotoAssetCarFuture]
    public var characteristics: Characteristics
    public var wishlist: [PartItem]

    public init(
        id: UUID = UUID(),
        type: VehicleType,
        name: String,
        photos: [PhotoAssetCarFuture] = [],
        characteristics: Characteristics = .init(),
        wishlist: [PartItem] = []
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.photos = photos
        self.characteristics = characteristics
        self.wishlist = wishlist
    }

    public var wishlistTotal: Double { wishlist.totalCost }
}
