//
//  VehicleDetailView.swift
//  CarFuture
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//
import SwiftUI
import CarFuturePackage

private enum VehicleDetailSheet: Identifiable {
    case addPart
    case editPart(PartItem)
    case editVehicle(Vehicle)

    var id: String {
        switch self {
        case .addPart: return "addPart"
        case .editPart(let p): return "editPart_\(p.id)"
        case .editVehicle(let v): return "editVehicle_\(v.id)"
        }
    }
}

struct VehicleDetailView: View {
    @EnvironmentObject private var store: GarageStore
    @Environment(\.dismiss) private var dismiss

    @State private var sheet: VehicleDetailSheet? = nil
    @State private var confirmDelete = false

    let vehicle: Vehicle

    private var currentVehicle: Vehicle {
        store.vehicles.first(where: { $0.id == vehicle.id }) ?? vehicle
    }

    var body: some View {
        List {
            Section {
                PhotoGalleryView(
                    images: currentVehicle.photos.compactMap { $0.image },
                    height: 360,
                    horizontalPadding: 0
                )
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)

                VehicleCard(
                    vehicleName: currentVehicle.name,
                    subtitle: currentVehicle.type.rawValue,
                    heroImage: currentVehicle.photos.first?.image,
                    statLeft: ("CV", currentVehicle.characteristics.horsepower.map(String.init) ?? "-"),
                    statRight: ("Kg", currentVehicle.characteristics.weightKg.map(String.init) ?? "-"),
                    showHero: false
                )
                .listRowInsets(EdgeInsets())
            }

            Section("Caractéristiques") {
                charRow("Poids", currentVehicle.characteristics.weightKg.map { "\($0) kg" })
                charRow("Places", currentVehicle.characteristics.seats.map(String.init))
                charRow("Chevaux", currentVehicle.characteristics.horsepower.map { "\($0) cv" })
                charRow("Couple", currentVehicle.characteristics.torqueNm.map { "\($0) Nm" })
                charRow("Année", currentVehicle.characteristics.year.map(String.init))
            }

            Section {
                HStack {
                    Text("Wishlist").font(.headline)
                    Spacer()
                    Text(currentVehicle.wishlistTotal.currencyString)
                        .foregroundStyle(.secondary)
                }

                if let idx = store.vehicles.firstIndex(where: { $0.id == currentVehicle.id }) {
                    ForEach(store.vehicles[idx].wishlist) { part in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(part.name).font(.body)
                                if let link = part.url, let url = URL(string: link) {
                                    Link(destination: url) {
                                        Label("Lien", systemImage: "link")
                                            .font(.caption)
                                    }
                                    .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            Text(part.price.currencyString)
                                .font(.headline)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { sheet = .editPart(part) }
                        .swipeActions {
                            Button { sheet = .editPart(part) } label: {
                                Label("Modifier", systemImage: "pencil")
                            }
                            .tint(.orange)
                            Button(role: .destructive) {
                                if let pIdx = store.vehicles[idx].wishlist.firstIndex(where: { $0.id == part.id }) {
                                    store.deletePart(at: IndexSet(integer: pIdx), vehicleID: currentVehicle.id)
                                }
                            } label: {
                                Label("Supprimer", systemImage: "trash")
                            }
                        }
                    }
                    .onDelete { offsets in
                        store.deletePart(at: offsets, vehicleID: currentVehicle.id)
                    }
                } else {
                    Text("Erreur: véhicule introuvable.")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(currentVehicle.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        sheet = .editVehicle(currentVehicle)
                    } label: {
                        Label("Modifier le véhicule", systemImage: "pencil")
                    }

                    Button {
                        sheet = .addPart
                    } label: {
                        Label("Ajouter une pièce", systemImage: "plus")
                    }

                    Divider()

                    Button(role: .destructive) {
                        confirmDelete = true
                    } label: {
                        Label("Supprimer le véhicule", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel("Actions")
            }
        }
        .sheet(item: $sheet) { sheet in
            switch sheet {
            case .addPart:
                PartEditorView { part in
                    store.addPart(part, to: currentVehicle.id)
                }
                .presentationDetents([.medium])

            case .editPart(let part):
                PartEditorView(existing: part) { updated in
                    store.updatePart(updated, vehicleID: currentVehicle.id)
                }
                .presentationDetents([.medium])

            case .editVehicle(let v):
                VehicleEditorView(vehicle: v) { updated in
                    store.updateVehicle(updated)
                }
                .presentationDetents([.large])
            }
        }
        .alert("Supprimer ce véhicule ?", isPresented: $confirmDelete) {
            Button("Annuler", role: .cancel) {}
            Button("Supprimer", role: .destructive) {
                if let idx = store.vehicles.firstIndex(where: { $0.id == currentVehicle.id }) {
                    store.deleteVehicles(at: IndexSet(integer: idx))
                    dismiss()
                }
            }
        } message: {
            Text("Cette action est irréversible.")
        }
    }

    private func charRow(_ label: String, _ value: String?) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value ?? "-")
        }
    }
}
