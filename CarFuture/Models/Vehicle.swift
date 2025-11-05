//
//  Vehicle.swift
//  CarFuture
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//
import Foundation
import CarFuturePackage

struct Vehicle: Identifiable, Codable, Hashable {
    let id: UUID
    var type: VehicleType
    var name: String
    var photos: [PhotoAsset]
    var characteristics: Characteristics
    var wishlist: [PartItem]

    init(
        id: UUID = UUID(),
        type: VehicleType,
        name: String,
        photos: [PhotoAsset] = [],
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

    var wishlistTotal: Double { wishlist.totalCost }
}
