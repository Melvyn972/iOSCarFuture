//
//  GarageStore.swift
//  CarFuture
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//
import Foundation
import SwiftUI
import CarFuturePackage
import UIKit

@MainActor
final class GarageStore: ObservableObject {
    @Published var vehicles: [Vehicle] = [] {
        didSet { persist() }
    }
    @Published var toBuy: [VehicleToBuy] = [] {
        didSet { persist() }
    }

    private var fgObserver: NSObjectProtocol?

    private static let saveURL: URL = {
        if let container = AppGroup.containerURL {
            return container.appendingPathComponent("garageStore.json")
        }
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

        importInbox()

        fgObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.importInbox()
            }
        }
    }

    deinit {
        if let fgObserver { NotificationCenter.default.removeObserver(fgObserver) }
    }

    private func importInbox() {
        let inboxItems = SharedInbox.load()
        guard !inboxItems.isEmpty else { return }
        withAnimation { self.toBuy.append(contentsOf: inboxItems) }
        SharedInbox.clear()
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
