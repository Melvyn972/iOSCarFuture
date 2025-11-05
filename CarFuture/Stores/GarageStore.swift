//
//  GarageStore.swift
//  CarFuture
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//
import Foundation
import SwiftUI
import CarFuturePackage

@MainActor
final class GarageStore: ObservableObject {
    @Published var vehicles: [Vehicle] = [] {
        didSet { persist() }
    }
    @Published var toBuy: [VehicleToBuy] = [] {
        didSet { persist() }
    }

    private static let saveURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("garageStore.json")
    }()

    private struct PersistedData: Codable {
        let vehicles: [Vehicle]
        let toBuy: [VehicleToBuy]
    }

    init() {
        #if targetEnvironment(simulator)
        self.vehicles = SampleData.vehicles
        self.toBuy = SampleData.toBuy
        #else
        if let loaded = Self.loadFromDisk() {
            self.vehicles = loaded.vehicles
            self.toBuy = loaded.toBuy
        } else {
            self.vehicles = []
            self.toBuy = []
        }
        #endif
    }

    private static func loadFromDisk() -> PersistedData? {
        do {
            let data = try Data(contentsOf: saveURL)
            let decoder = JSONDecoder()
            return try decoder.decode(PersistedData.self, from: data)
        } catch {
            return nil
        }
    }

    private func persist() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted]
            let payload = PersistedData(vehicles: vehicles, toBuy: toBuy)
            let data = try encoder.encode(payload)
            try data.write(to: Self.saveURL, options: [.atomic])
        } catch {
            #if DEBUG
            print("GarageStore persist error:", error)
            #endif
        }
    }

    func addVehicle(_ vehicle: Vehicle) {
        withAnimation { vehicles.append(vehicle) }
    }

    func updateVehicle(_ vehicle: Vehicle) {
        guard let idx = vehicles.firstIndex(where: { $0.id == vehicle.id }) else { return }
        withAnimation { vehicles[idx] = vehicle }
    }

    func deleteVehicles(at offsets: IndexSet) {
        withAnimation { vehicles.remove(atOffsets: offsets) }
    }

    func addPart(_ part: PartItem, to vehicleID: UUID) {
        guard let idx = vehicles.firstIndex(where: { $0.id == vehicleID }) else { return }
        withAnimation { vehicles[idx].wishlist.append(part) }
    }

    func updatePart(_ part: PartItem, vehicleID: UUID) {
        guard let vIdx = vehicles.firstIndex(where: { $0.id == vehicleID }) else { return }
        guard let pIdx = vehicles[vIdx].wishlist.firstIndex(where: { $0.id == part.id }) else { return }
        withAnimation { vehicles[vIdx].wishlist[pIdx] = part }
    }

    func deletePart(at offsets: IndexSet, vehicleID: UUID) {
        guard let idx = vehicles.firstIndex(where: { $0.id == vehicleID }) else { return }
        withAnimation { vehicles[idx].wishlist.remove(atOffsets: offsets) }
    }

    func addVehicleToBuy(_ v: VehicleToBuy) {
        withAnimation { toBuy.append(v) }
    }

    func updateVehicleToBuy(_ v: VehicleToBuy) {
        guard let idx = toBuy.firstIndex(where: { $0.id == v.id }) else { return }
        withAnimation { toBuy[idx] = v }
    }

    func deleteToBuy(at offsets: IndexSet) {
        withAnimation { toBuy.remove(atOffsets: offsets) }
    }

    var globalWishlistTotal: Double {
        vehicles.map(\.wishlistTotal).reduce(0, +)
    }
}

enum SampleData {
    static let vehicles: [Vehicle] = [
        Vehicle(type: .car, name: "Mazda MX-5",
                photos: [],
                characteristics: .init(weightKg: 980, seats: 2, horsepower: 181, torqueNm: 205, year: 2020),
                wishlist: [PartItem(name: "Ligne Inox", url: nil, price: 899.0),
                           PartItem(name: "Jantes 17\"", url: nil, price: 1200.0)]),

        Vehicle(type: .motorcycle, name: "Kawasaki Z900",
                photos: [],
                characteristics: .init(weightKg: 210, seats: 2, horsepower: 125, torqueNm: 98, year: 2020),
                wishlist: [PartItem(name: "Silencieux Akrapovic", url: nil, price: 800.0)]),

        Vehicle(type: .car, name: "Toyota Supra MK5",
                photos: [],
                characteristics: .init(weightKg: 1490, seats: 2, horsepower: 335, torqueNm: 500, year: 2021),
                wishlist: [PartItem(name: "Kit Turbo", url: nil, price: 4500.0),
                           PartItem(name: "Suspensions Bilstein", url: nil, price: 1200.0)]),

        Vehicle(type: .car, name: "BMW M4",
                photos: [],
                characteristics: .init(weightKg: 1700, seats: 4, horsepower: 503, torqueNm: 650, year: 2021),
                wishlist: [PartItem(name: "Échappement Akrapovic", url: nil, price: 2000.0),
                           PartItem(name: "Jantes Forgées", url: nil, price: 2500.0)]),

        Vehicle(type: .car, name: "Nissan GT-R R35",
                photos: [],
                characteristics: .init(weightKg: 1730, seats: 2, horsepower: 565, torqueNm: 633, year: 2020),
                wishlist: [PartItem(name: "Kit Performance Nismo", url: nil, price: 8000.0),
                           PartItem(name: "Turbo Garret", url: nil, price: 3000.0)]),

        Vehicle(type: .car, name: "Audi RS5",
                photos: [],
                characteristics: .init(weightKg: 1885, seats: 4, horsepower: 450, torqueNm: 600, year: 2021),
                wishlist: [PartItem(name: "Boîte à Air Performance", url: nil, price: 1200.0),
                           PartItem(name: "Système de Freinage carbone", url: nil, price: 3500.0)]),

        Vehicle(type: .car, name: "Subaru WRX STI",
                photos: [],
                characteristics: .init(weightKg: 1580, seats: 5, horsepower: 310, torqueNm: 400, year: 2020),
                wishlist: [PartItem(name: "Turbo Bilstein", url: nil, price: 2000.0),
                           PartItem(name: "Recaro Seats", url: nil, price: 2500.0)]),

        Vehicle(type: .car, name: "Porsche 911 Turbo S",
                photos: [],
                characteristics: .init(weightKg: 1640, seats: 2, horsepower: 640, torqueNm: 800, year: 2021),
                wishlist: [PartItem(name: "Échappement Carbotec", url: nil, price: 3500.0),
                           PartItem(name: "Kit Turbo Performance", url: nil, price: 4500.0)]),
    ]

    static let toBuy: [VehicleToBuy] = [
        VehicleToBuy(type: .car, name: "Toyota GR Yaris",
                     listingURL: "https://example.com/gryaris",
                     price: 32500,
                     notes: "Voir l’historique d’entretien, vérifier pneus."),

        VehicleToBuy(type: .car, name: "Nissan 370Z",
                     listingURL: "https://example.com/370z",
                     price: 29900,
                     notes: "Contrôler l’état des suspensions, vérifier les freins."),

        VehicleToBuy(type: .car, name: "BMW M2 Competition",
                     listingURL: "https://example.com/bmw_m2",
                     price: 55000,
                     notes: "Vérifier les antécédents d’accidents, tester la boîte de vitesses."),

        VehicleToBuy(type: .car, name: "Honda Civic Type R",
                     listingURL: "https://example.com/civic_type_r",
                     price: 35000,
                     notes: "Contrôler la carrosserie pour des bosses, vérifier l’usure des pneus."),

        VehicleToBuy(type: .car, name: "Audi RS3",
                     listingURL: "https://example.com/audi_rs3",
                     price: 59000,
                     notes: "Vérifier l’historique d’entretien, inspecter les plaquettes de frein."),

        VehicleToBuy(type: .car, name: "Porsche Cayman S",
                     listingURL: "https://example.com/porsche_cayman_s",
                     price: 49900,
                     notes: "S’assurer qu’il n’y a pas de fuites d’huile, tester le moteur."),

        VehicleToBuy(type: .car, name: "Subaru BRZ",
                     listingURL: "https://example.com/subaru_brz",
                     price: 28000,
                     notes: "Vérifier le système de refroidissement, inspecter les suspensions."),

        VehicleToBuy(type: .car, name: "Mercedes-Benz A45 AMG",
                     listingURL: "https://example.com/mercedes_a45_amg",
                     price: 67000,
                     notes: "Vérifier l’historique d’entretien, tester les amortisseurs.")
    ]
}

extension Double {
    var currencyString: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = Locale.current.currency?.identifier ?? "EUR"
        return f.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
